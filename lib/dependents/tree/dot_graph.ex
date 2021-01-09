defmodule Dependents.Tree.DotGraph do
  @moduledoc """
  Converts a DOT graph (`deps_tree.dot`) into a `dependents tree`.
  Also returns the folder of a DOT graph given its `path`.

  """

  alias Dependents.Tree

  @doc ~S"""
  A DOT graph line maps an app to a dependency (`app` -> `dep`).

  E.g. `"dependents_tree" -> "io_ansi_table" [label="~> 1.0"]`

  If `dep` is a dependency of `app` then `app` is dependent on `dep`.
  Returns a `dependents tree` where each dependency is a `tree app`
  and `folder` is its unique `tree dep`.

  All `tree apps` and `tree deps` must be local apps i.e. project folders.

  ## Examples

      iex> alias Dependents.Tree.DotGraph
      iex> proj_dir = "c:/Users/Ray/Documents/ex_dev/projects"
      iex> folder = "dependents_tree"
      iex> path = "#{proj_dir}/#{folder}/deps_tree.dot"
      iex> folders = [
      ...>   "dependents_tree", "io_ansi_table", "io_ansi_plus",
      ...>   "file_only_logger", "log_reset", "map_sorter", "persist_config"
      ...> ]
      iex> DotGraph.to_tree({path, folder}, folders)
      %{
        dependents_tree: [],
        io_ansi_table: [:dependents_tree],
        persist_config: [:dependents_tree]
      }
  """
  @spec to_tree({Path.t(), folder :: String.t()}, [String.t()]) :: Tree.t()
  def to_tree({path, folder} = _path_and_folder, folders) do
    for line <- File.stream!(path), into: %{} do
      with [app, dep] <- String.split(line, "->") |> Enum.map(&String.trim/1),
           [_full, app] <- Regex.run(~r|^"(\w+)"$|, app),
           true <- app == folder,
           [_full, dep] <- Regex.run(~r|^"(\w+)" \[.+\]$|, dep),
           true <- dep in folders do
        {String.to_atom(dep), [String.to_atom(folder)]}
      else
        _non_matched -> {String.to_atom(folder), []}
      end
    end
  end

  @doc ~S"""
  Returns the folder of a DOT graph (`deps_tree.dot`) given its `path`.

  ## Examples

      iex> alias Dependents.Tree.DotGraph
      iex> proj_dir = "c:/Users/Ray/Documents/ex_dev/projects"
      iex> path1 = "#{proj_dir}/file_only_logger/deps_tree.dot"
      iex> path2 = "#{proj_dir}/file only logger/deps_tree.dot"
      iex> {DotGraph.folder(path1), DotGraph.folder(path2)}
      {"file_only_logger", nil}
  """
  @spec folder(Path.t()) :: String.t() | nil
  def folder(path) do
    case Regex.run(~r|^.+/(\w+)/deps_tree.dot$|, path) do
      [_full, folder] -> folder
      # folder may contain spaces (not \w)
      nil -> nil
    end
  end
end
