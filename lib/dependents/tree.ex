defmodule Dependents.Tree do
  @moduledoc """
  Converts the dependents tree of one or all `apps` to a list of `tree_maps`.
  """

  use PersistConfig

  alias __MODULE__.{Adaptor, Digraph, Proxy}

  @typedoc "Application"
  @type app :: Application.app()
  @typedoc "Dependent (not dependency)"
  @type dep :: Application.app()
  @typedoc "Dependents tree mapping each local app to its local dependents"
  @type t :: %{app => [dep]}
  @typedoc "Tree map for printing"
  @type tree_map :: %{
          rank: pos_integer,
          chunk: pos_integer,
          ver: String.t() | nil,
          hex: String.t() | nil,
          app: app | nil,
          deps: non_neg_integer | nil,
          dependent_1: dep | nil,
          dependent_2: dep | nil,
          dependent_3: dep | nil,
          dependent_4: dep | nil
        }
  @typedoc "Ranks of local apps in a dependents tree"
  @type ranks :: %{app => pos_integer}

  @doc """
  Converts the dependents tree of one or all `apps` to a list of `tree_maps`.
  """
  @spec to_maps(:* | app) :: [tree_map]
  def to_maps(:*) do
    tree = new()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    Adaptor.tree_to_maps(tree, ranks)
  end

  def to_maps(app) do
    tree = new()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    deps = Digraph.dependents(app, digraph)
    Map.take(tree, [app | deps]) |> Adaptor.tree_to_maps(ranks)
  end

  defdelegate new, to: Proxy
end
