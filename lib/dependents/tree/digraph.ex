defmodule Dependents.Tree.Digraph do
  @moduledoc """
  In a diagram of a graph, a vertex is usually represented by a circle with a
  label, and an edge is represented by an arrow extending from one vertex to
  another.

  Here vertices are apps and edges are arrows extending from an app to its
  dependents.
  """

  alias Dependents.Tree

  @typedoc "Erlang digraph"
  @type t :: :digraph.graph()

  @doc """
  Converts a `Dependents.Tree` into a digraph.
  """
  @spec from_tree(Tree.t()) :: t
  def from_tree(tree) do
    # A digraph is a mutable data structure.
    digraph = :digraph.new([:acyclic])

    for app <- Map.keys(tree) do
      :digraph.add_vertex(digraph, app)
    end

    for {app, [_dcys | deps]} <- tree, deps != [] do
      for dep <- deps do
        # The edge is emanating from `app` and incident on `dep`.
        :digraph.add_edge(digraph, app, dep)
      end
    end

    digraph
  end

  @doc """
  Assigns each app (vertex) to its topological rank in `digraph`.
  """
  @spec ranks(t) :: Tree.ranks()
  def ranks(digraph) do
    :digraph_utils.topsort(digraph)
    |> Enum.with_index(1)
    |> Map.new()
  end

  @doc """
  Returns a recursive list of the out-neighbors of `app`.

  If an edge is emanating from v and incident on w, then w is said to be an
  out-neighbor of v, and v is said to be an in-neighbor of w.
  """
  @spec dependents(t, Tree.app()) :: [Tree.dep()]
  def dependents(digraph, app) do
    dependents(digraph, [app], [])
  end

  ## Private functions

  @spec dependents(t, [Tree.app()], [Tree.dep()]) :: [Tree.dep()]
  defp dependents(_digraph, [], deps), do: Enum.uniq(deps)

  defp dependents(digraph, [app | apps], deps) do
    neighbors = :digraph.out_neighbours(digraph, app)
    dependents(digraph, apps ++ neighbors, deps ++ neighbors)
  end
end
