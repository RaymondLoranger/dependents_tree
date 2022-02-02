defmodule Dependents.Tree.DotGraph do
  @moduledoc """
  Converts a DOT graph (file `deps_tree.dot`) into a `Dependents.Tree`.
  Also returns the directory of a DOT graph given its path.
  """

  alias Dependents.Tree

  @doc ~S"""
  Returns the `Dependents.Tree` of a DOT graph.

  A DOT graph line maps an app to a dependency. For example:

  ```
  "noaa_observations"
  "noaa_observations" -> "ex_doc" [label="~> 0.22"]
  "ex_doc" -> "earmark_parser" [label="~> 1.4.0"]
  "noaa_observations" -> "io_ansi_table" [label="~> 1.0"]
  "noaa_observations" -> "persist_config" [label="~> 0.4"]
  ```

  Converted into a `Dependents.Tree`, the above 5 lines become:

  ```
  %{
    # Number of local dependencies...
    noaa_observations: [2],
    io_ansi_table: [:noaa_observations],
    persist_config: [:noaa_observations]
  }
  ```

  ## Examples

      iex> alias Dependents.Tree.DotGraph
      iex> proj_dir = "c:/Users/Ray/Documents/ex_dev/projects"
      iex> dir = "noaa_observations"
      iex> path = "#{proj_dir}/#{dir}/deps_tree.dot"
      iex> dirs = ["io_ansi_table", "log_reset", "persist_config", dir]
      iex> DotGraph.to_tree({path, dir}, dirs)
      %{
        noaa_observations: [3],
        log_reset: [:noaa_observations],
        io_ansi_table: [:noaa_observations],
        persist_config: [:noaa_observations]
      }
  """
  @spec to_tree({Path.t(), dir :: String.t()}, [String.t()]) :: Tree.t()
  def to_tree({path, dir} = _dot_graph_path_and_dir, dirs) do
    tree =
      for line <- File.stream!(path), into: %{} do
        with [app, dep] <- String.split(line, "->") |> Enum.map(&String.trim/1),
             [_full, app] <- Regex.run(~r|^"(\w+)"$|, app),
             true <- app == dir,
             [_full, dep] <- Regex.run(~r|^"(\w+)" \[.+\]$|, dep),
             true <- dep in dirs do
          {String.to_atom(dep), [String.to_atom(dir)]}
        else
          _non_matched -> {String.to_atom(dir), nil}
        end
      end

    # [Number of dependencies for `app`]...
    Map.put(tree, String.to_atom(dir), [map_size(tree) - 1])
  end

  @doc ~S"""
  Returns the directory of a DOT graph (file `deps_tree.dot`) given its `path`.

  ## Examples

      iex> alias Dependents.Tree.DotGraph
      iex> proj_dir = "c:/Users/Ray/Documents/ex_dev/projects"
      iex> path1 = "#{proj_dir}/file_only_logger/deps_tree.dot"
      iex> path2 = "#{proj_dir}/file only logger/deps_tree.dot"
      iex> {DotGraph.dir(path1), DotGraph.dir(path2)}
      {"file_only_logger", nil}
  """
  @spec dir(Path.t()) :: String.t() | nil
  def dir(path) do
    case Regex.run(~r|^.+/(\w+)/deps_tree.dot$|, path) do
      [_full, dir] -> dir
      # dir may contain spaces (not \w)
      nil -> nil
    end
  end
end
