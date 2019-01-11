defmodule Dependents.Tree.Digraph do
  @typedoc "Application"
  @type app :: Application.app()

  @typedoc "Dependent (not dependency)"
  @type dep :: Application.app()

  @spec from_tree(tree :: %{app => [dep]}) :: :digraph.graph()
  def from_tree(tree) do
    digraph = :digraph.new()

    for app <- Map.keys(tree) do
      :digraph.add_vertex(digraph, app)
    end

    for {app, deps} <- tree do
      # Edge must not create a cycle in an acyclic digraph...
      for dep when dep != :mix_tasks <- deps do
        :digraph.add_edge(digraph, app, dep)
      end
    end

    digraph
  end

  @spec dependents(app, :digraph.graph()) :: [dep]
  def dependents(app, digraph) do
    dependents(digraph, [app], [])
  end

  @spec ranks(:digraph.graph()) :: map
  def ranks(digraph) do
    digraph
    |> :digraph_utils.topsort()
    |> Enum.with_index(1)
    |> Map.new()
  end

  ## Private functions

  @spec dependents(:digraph.graph(), [app], [dep]) :: [dep]
  defp dependents(_digraph, [], deps), do: Enum.uniq(deps)

  defp dependents(digraph, [app | apps], deps) do
    neighbors = :digraph.out_neighbours(digraph, app)
    dependents(digraph, apps ++ neighbors, deps ++ neighbors)
  end
end
