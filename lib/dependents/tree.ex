defmodule Dependents.Tree do
  @moduledoc """
  Converts the `Dependents.Tree` of all or a single app into table maps.
  
  The dependencies of an app are specified in the `mix.exs` file.
  _Dependents_ of an app are those apps using it as a dependency.
  """

  use PersistConfig

  alias __MODULE__.{Digraph, Proxy}

  @typedoc "Local app"
  @type app :: Application.app()
  @typedoc "Number of local dependencies"
  @type dcys :: non_neg_integer
  @typedoc "Local dependent"
  @type dep :: Application.app()
  @typedoc "Number of local dependents"
  @type deps :: non_neg_integer
  @typedoc "Topological rank"
  @type rank :: pos_integer
  @typedoc "Ranks of topologically ordered apps"
  @type ranks :: %{app => rank}
  @typedoc "Tree mapping local apps to local dependents"
  @type t :: %{app => [dcys | dep]}
  @typedoc "Table map for printing"
  @type table_map :: %{
          rank: rank,
          chunk: pos_integer,
          ver: String.t() | nil,
          hex: String.t() | nil,
          app: app | nil,
          dcys: dcys | nil,
          deps: deps | nil,
          dependent_1: dep | nil,
          dependent_2: dep | nil,
          dependent_3: dep | nil,
          dependent_4: dep | nil
        }

  @doc """
  Converts the `Dependents.Tree` of all or a single app into table maps.
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
    deps = Digraph.dependents(digraph, app)
    Map.take(tree, [app | deps]) |> to_maps(ranks)
  end

  @spec new :: t
  defdelegate new, to: Proxy

  @spec to_maps(t, ranks) :: [table_map]
  defdelegate to_maps(tree, ranks), to: Proxy

  @spec project_dir :: String.t()
  def project_dir, do: get_env(:project_dir)
end
