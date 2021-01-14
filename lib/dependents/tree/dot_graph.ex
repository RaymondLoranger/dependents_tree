defmodule Dependents.Tree.DotGraph do
  @moduledoc """
  Converts a DOT graph (deps_tree.dot) into a
  [`dependents tree`](`t:Dependents.Tree.t/0`).
  Also returns the folder of a DOT graph given its path.

  """

  alias Dependents.Tree

  @doc ~S"""
  A DOT graph line maps an app to a dependency. For example, consider these
  few lines from DOT graph `.../projects/noaa_observations/deps_tree.dot`:

  ```
  "noaa_observations" -> "ex_doc" [label="~> 0.22"]
  "ex_doc" -> "earmark_parser" [label="~> 1.4.0"]
  "noaa_observations" -> "io_ansi_table" [label="~> 1.0"]
  "noaa_observations" -> "persist_config" [label="~> 0.4"]
  ```

  Converted into a [`dependents tree`](`t:Dependents.Tree.t/0`),
  the above lines become:

  ```
  %{
    ex_doc: [:noaa_observations],
    earmark_parser: [:ex_doc],
    io_ansi_table: [:noaa_observations],
    persist_config: [:noaa_observations]
  }
  ```

  Returns such a [`dependents tree`](`t:Dependents.Tree.t/0`) but where
  [`apps`](`t:Dependents.Tree.app/0`) and [`deps`](`t:Dependents.Tree.dep/0`)
  are local projects (`folder` or in `folders`).

  ## Examples

      iex> alias Dependents.Tree.DotGraph
      iex> proj_dir = "c:/Users/Ray/Documents/ex_dev/projects"
      iex> folder = "noaa_observations"
      iex> path = "#{proj_dir}/#{folder}/deps_tree.dot"
      iex> folders = ["io_ansi_table", "log_reset", "persist_config"]
      iex> DotGraph.to_tree({path, folder}, folders)
      %{
        noaa_observations: [],
        log_reset: [:noaa_observations],
        io_ansi_table: [:noaa_observations],
        persist_config: [:noaa_observations]
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
  Returns the folder of a DOT graph (deps_tree.dot) given its `path`.

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
