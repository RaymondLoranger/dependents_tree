defmodule Dependents.Tree.Adaptor do
  alias Dependents.Tree.Parser

  @typedoc "Application"
  @type app :: Application.app()
  @typedoc "Dependent (not dependency)"
  @type dep :: Application.app()
  @type table_map :: map

  @spec tree_to_maps(%{app => [dep]}, %{app => pos_integer}) :: [table_map]
  def tree_to_maps(tree, ranks) do
    for {app, deps} <- tree do
      chunk_deps(deps)
      |> Enum.with_index(1)
      |> Enum.map(fn {[dep1, dep2, dep3, dep4], index} ->
        _table_map = %{
          rank: ranks[app],
          chunk: index,
          ver: app |> Parser.ver() |> zap_dup(index),
          hex: app |> Parser.hex?() |> zap_dup(index),
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

  @spec chunk_deps([dep]) :: [[dep | nil]]
  def chunk_deps([]), do: [[nil, nil, nil, nil]]
  def chunk_deps(deps), do: Enum.chunk_every(deps, 4, 4, [nil, nil, nil])

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
