defmodule Dependents.Tree do
  @moduledoc "Prints the dependents tree of one or all local apps."

  alias Dependents.Tree.{Adaptor, Digraph, Parser}
  alias IO.ANSI.Table

  @typedoc "Application"
  @type app :: Application.app()

  @spec print(app | :*) :: :ok
  def print(:* = _app) do
    tree = Parser.dependents_tree()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)

    tree
    |> Adaptor.tree_to_maps(ranks)
    |> Table.format()
  end

  def print(app) when is_atom(app) do
    tree = Parser.dependents_tree()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    deps = Digraph.dependents(app, digraph)

    tree
    |> Map.take([app | deps])
    |> Adaptor.tree_to_maps(ranks)
    |> Table.format()
  end
end
