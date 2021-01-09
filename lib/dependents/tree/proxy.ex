defmodule Dependents.Tree.Proxy do
  @moduledoc """
  Creates a `dependents tree` of all local apps.
  Also converts a `dependents tree` into a list of `table_maps`.
  """

  alias Dependents.Tree.DotGraph
  alias Dependents.Tree

  @cwd File.cwd!()
  @glob Path.join(@cwd, "../*/deps_tree.dot") |> Path.expand()

  @doc """
  Creates a `dependents tree` of all local apps.

  ## Examples

      iex> alias Dependents.Tree.Proxy
      iex> tree = Proxy.new()
      iex> %{file_only_logger: deps1, io_ansi_table: deps2} = tree
      iex> Enum.all?(deps1, &is_atom/1) and Enum.all?(deps2, &is_atom/1)
      true
  """
  @spec new :: Tree.t()
  def new do
    paths = Path.wildcard(@glob)
    folders = Enum.map(paths, &DotGraph.folder/1)

    Enum.zip(paths, folders)
    |> Enum.reject(fn {_path, folder} -> is_nil(folder) end)
    |> Enum.map(&DotGraph.to_tree(&1, folders))
    |> Enum.reduce(%{}, fn tree, full_tree ->
      Map.merge(full_tree, tree, fn
        _app, deps, [] -> deps
        _app, deps, [dep] -> [dep | deps]
      end)
    end)
  end

  @doc """
  Converts a `dependents tree` into a list of `table_maps`.

  ## Examples

      iex> alias Dependents.Tree.Proxy
      iex> tree = %{
      ...>   io_ansi_table: [:noaa_observations, :github_issues],
      ...>   map_sorter: [:io_ansi_table]
      ...> }
      iex> ranks = %{io_ansi_table: 27, map_sorter: 25}
      iex> Proxy.to_maps(tree, ranks)
      [
        %{
          app: :io_ansi_table, chunk: 1,
          dependent_1: :noaa_observations,
          dependent_2: :github_issues,
          dependent_3: nil,
          dependent_4: nil,
          deps: 2, hex: "Y", rank: 27, ver: "1.0.6"
        },
        %{
          app: :map_sorter, chunk: 1,
          dependent_1: :io_ansi_table,
          dependent_2: nil,
          dependent_3: nil,
          dependent_4: nil,
          deps: 1, hex: "Y", rank: 25, ver: "0.2.36"
        }
      ]
  """
  @spec to_maps(Tree.t(), Tree.ranks()) :: [Tree.table_map()]
  def to_maps(tree, ranks) do
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
