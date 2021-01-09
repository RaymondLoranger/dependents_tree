defmodule Dependents.Tree do
  @moduledoc """
  Converts the `dependents tree` of all or a single `app` into `table_maps`.
  """

  use PersistConfig

  alias __MODULE__.{Digraph, Proxy}

  @typedoc "Application"
  @type app :: Application.app()
  @typedoc "Dependent (not dependency)"
  @type dep :: Application.app()
  @typedoc "Ranks of local apps in a dependents tree"
  @type ranks :: %{app => pos_integer}
  @typedoc "Dependents tree mapping each local app to its local dependents"
  @type t :: %{app => [dep]}
  @typedoc "Table map for printing"
  @type table_map :: %{
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

  @doc """
  Converts the `dependents tree` of all or a single `app` into `table_maps`.
  """
  @spec to_maps(:* | app) :: [table_map]
  def to_maps(:*) do
    tree = new()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    to_maps(tree, ranks)
  end

  def to_maps(app) do
    tree = new()
    digraph = Digraph.from_tree(tree)
    ranks = Digraph.ranks(digraph)
    deps = Digraph.dependents(app, digraph)
    Map.take(tree, [app | deps]) |> to_maps(ranks)
  end

  @spec new :: t
  defdelegate new, to: Proxy

  @spec to_maps(t, ranks) :: [table_map]
  defdelegate to_maps(tree, ranks), to: Proxy
end
