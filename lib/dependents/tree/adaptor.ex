defmodule Dependents.Tree.Adaptor do
  @moduledoc """
  Converts a `dependents tree` into a list of `tree_maps`.
  """

  alias Dependents.Tree

  @cwd File.cwd!()

  @doc """
  Converts a `dependents tree` into a list of `tree_maps`.

  ## Examples

      iex> alias Dependents.Tree.Adaptor
      iex> tree = %{
      ...>   io_ansi_table: [:noaa_observations, :github_issues],
      ...>   map_sorter: [:io_ansi_table]
      ...> }
      iex> ranks = %{io_ansi_table: 27, map_sorter: 25}
      iex> Adaptor.tree_to_maps(tree, ranks)
      [
        %{app: :io_ansi_table, chunk: 1,
          dependent_1: :noaa_observations,
          dependent_2: :github_issues,
          dependent_3: nil,
          dependent_4: nil,
          deps: 2, hex: "Y", rank: 27, ver: "1.0.6"
        },
        %{app: :map_sorter, chunk: 1,
          dependent_1: :io_ansi_table,
          dependent_2: nil,
          dependent_3: nil,
          dependent_4: nil,
          deps: 1, hex: "Y", rank: 25, ver: "0.2.36"
        }
      ]
  """
  @spec tree_to_maps(Tree.t(), Tree.ranks()) :: [Tree.tree_map()]
  def tree_to_maps(tree, ranks) do
    for {app, deps} <- tree do
      chunk_deps(deps)
      |> Enum.with_index(1)
      |> Enum.map(fn {[dep1, dep2, dep3, dep4], index} ->
        %{
          rank: ranks[app],
          chunk: index,
          ver: ver(app) |> zap_dup(index),
          hex: hex?(app) |> zap_dup(index),
          app: zap_dup(app, index),
          deps: zap_dup(length(deps), index),
          dependent_1: dep1,
          dependent_2: dep2,
          dependent_3: dep3,
          dependent_4: dep4
        }
      end)
    end
    |> List.flatten()
  end

  ## Private functions

  @spec ver(Tree.app()) :: String.t()
  def ver(app) do
    [_full, major, minor, patch] =
      Regex.run(~r|version: "(\d+)\.(\d+)\.(\d+)"|, mix_text(app))

    "#{major}.#{minor}.#{patch}"
  end

  @spec hex?(Tree.app()) :: boolean
  def hex?(app) do
    (Regex.run(~r|package: \w+|, mix_text(app)) && true) || false
  end

  @spec mix_text(Tree.app()) :: String.t()
  defp mix_text(app) do
    Path.join(@cwd, "/../#{app}/mix.exs") |> Path.expand() |> File.read!()
  end

  @spec chunk_deps([Tree.dep()]) :: [[Tree.dep() | nil]]
  defp chunk_deps([]), do: [[nil, nil, nil, nil]]
  defp chunk_deps(deps), do: Enum.chunk_every(deps, 4, 4, [nil, nil, nil])

  @spec zap_dup(any, non_neg_integer) :: any | nil
  defp zap_dup(true, index) do
    zap_dup("Y", index)
  end

  defp zap_dup(false, index) do
    zap_dup("n", index)
  end

  defp zap_dup(value, index) do
    if index == 1, do: value, else: nil
  end
end
