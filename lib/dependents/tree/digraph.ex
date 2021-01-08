defmodule Dependents.Tree.Digraph do
  alias Dependents.Tree

  @spec from_tree(Tree.t()) :: :digraph.graph()
  def from_tree(tree) do
    digraph = :digraph.new([:acyclic])

    for app <- Map.keys(tree) do
      :digraph.add_vertex(digraph, app)
    end

    for {app, deps} <- tree do
      # Edge must not create a cycle in an acyclic digraph...
      for dep <- deps, dep != :mix_tasks do
        :digraph.add_edge(digraph, app, dep)
      end
    end

    digraph
  end

  @spec ranks(:digraph.graph()) :: Tree.ranks()
  def ranks(digraph) do
    :digraph_utils.topsort(digraph)
    |> Enum.with_index(1)
    |> Map.new()
  end

  @spec dependents(Tree.app(), :digraph.graph()) :: [Tree.dep()]
  def dependents(app, digraph) do
    dependents(digraph, [app], [])
  end

  ## Private functions

  @spec dependents(:digraph.graph(), [Tree.app()], [Tree.dep()]) :: [Tree.dep()]
  defp dependents(_digraph, [], deps), do: Enum.uniq(deps)

  defp dependents(digraph, [app | apps], deps) do
    neighbors = :digraph.out_neighbours(digraph, app)
    dependents(digraph, apps ++ neighbors, deps ++ neighbors)
  end
end
