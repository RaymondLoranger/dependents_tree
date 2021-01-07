defmodule Dependents.Tree do
  @moduledoc "Prints the dependents tree of one or all local apps."

  use PersistConfig

  alias Dependents.Tree.{Adaptor, Digraph, Parser}

  @typedoc "Application"
  @type app :: Application.app()

  @spec to_maps(atom) :: [table_map :: map]
  def to_maps(:*) do
    tree = Parser.dependents_tree()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    Adaptor.tree_to_maps(tree, ranks)
  end

  def to_maps(app) do
    tree = Parser.dependents_tree()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    deps = Digraph.dependents(app, digraph)
    Map.take(tree, [app | deps]) |> Adaptor.tree_to_maps(ranks)
  end
end
