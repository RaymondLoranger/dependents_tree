defmodule Dependents.Tree do
  @moduledoc """
  Converts the [`dependents tree`](`t:Dependents.Tree.t/0`) of all or a single
  app into table maps.
  """

  use PersistConfig

  alias __MODULE__.{Digraph, Proxy}

  @typedoc "Application"
  @type app :: Application.app()
  @typedoc "Dependent (not dependency)"
  @type dep :: Application.app()
  @typedoc "Ranks of topologically sorted apps in a dependents tree"
  @type ranks :: %{app => pos_integer}
  @typedoc "Dependents tree mapping each app to its dependents"
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
  Converts the [`dependents tree`](`t:Dependents.Tree.t/0`) of all or a single
  app into [`table maps`](`t:Dependents.Tree.table_map/0`).
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

  @spec project_dir :: String.t()
  def project_dir, do: get_env(:project_dir)
end
