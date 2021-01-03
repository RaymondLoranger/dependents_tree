defmodule Dependents.Tree do
  @moduledoc "Prints the dependents tree of one or all local apps."

  use PersistConfig

  alias Dependents.Tree.{Adaptor, Digraph, Parser}
  alias IO.ANSI.Table

  @table_spec get_env(:table_spec)

  @typedoc "Application"
  @type app :: Application.app()

  @dialyzer {:nowarn_function, print: 1}
  @spec print(:all | app) :: :ok
  def print(:all = _app) do
    tree = Parser.dependents_tree()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)

    tree
    |> Adaptor.tree_to_maps(ranks)
    |> Table.write(@table_spec)
  end

  def print(app) when is_atom(app) do
    tree = Parser.dependents_tree()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    deps = Digraph.dependents(app, digraph)

    Map.take(tree, [app | deps])
    |> Adaptor.tree_to_maps(ranks)
    |> Table.write(@table_spec)
  end
end
