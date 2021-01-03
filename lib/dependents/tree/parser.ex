defmodule Dependents.Tree.Parser do
  @typedoc "Application"
  @type app :: Application.app()

  @typedoc "Dependent (not dependency)"
  @type dep :: Application.app()

  @cwd File.cwd!()
  # mix deps.tree --format dot
  @folder_regex ~r|^.+/(\w+)/deps_tree.dot$|
  @glob @cwd |> Path.join("../*/deps_tree.dot") |> Path.expand()

  @doc """
  Returns a map representing the complete dependents tree.

  ## Examples

      iex> alias Dependents.Tree.Parser
      iex> tree = Parser.dependents_tree()
      iex> %{file_only_logger: deps1, io_ansi_table: deps2} = tree
      iex> Enum.all?(deps1, &is_atom/1) and Enum.all?(deps2, &is_atom/1)
      true
  """
  @spec dependents_tree :: tree :: %{app => [dep]}
  def dependents_tree do
    paths = Path.wildcard(@glob)
    folders = folders(paths)

    Enum.zip(paths, folders)
    |> Enum.reject(fn {_path, folder} -> is_nil(folder) end)
    |> Enum.map(&path_to_map(&1, folders))
    |> Enum.reduce(%{}, fn map, acc ->
      Map.merge(acc, map, fn
        _app, deps, [] -> deps
        _app, deps, [dep] -> [dep | deps]
      end)
    end)
  end

  @spec ver(app) :: String.t()
  def ver(app) do
    [_full, major, minor, patch] =
      Regex.run(~r|version: "(\d+)\.(\d+)\.(\d+)"|, mix_text(app))

    "#{major}.#{minor}.#{patch}"
  end

  @spec hex?(app) :: boolean
  def hex?(app) do
    (Regex.run(~r|package: \w+|, mix_text(app)) && true) || false
  end

  ## Private functions

  @spec mix_text(app) :: String.t()
  defp mix_text(app) do
    Path.join(@cwd, "/../#{app}/mix.exs") |> Path.expand() |> File.read!()
  end

  # @doc """
  # Finds the folder of each `path`.

  # ## Examples

  #     iex> alias Dependents.Tree.Parser
  #     iex> paths = [
  #     ...>   "c:/Users/Ray/Documents/ex_dev/projects/cards/deps_tree.dot",
  #     ...>   "c:/Users/Ray/Documents/ex_dev/projects/gallows/deps_tree.dot",
  #     ...>   "c:/Users/Ray/Documents/ex_dev/projects/not good/deps_tree.dot"
  #     ...> ]
  #     iex> Parser.folders(paths)
  #     ["cards", "gallows", nil]
  # """
  @spec folders([Path.t()]) :: [String.t() | nil]
  defp folders(paths) do
    for path <- paths do
      case Regex.run(@folder_regex, path) do
        [_full, folder] -> folder
        # folder may contain spaces (not \w)
        nil -> nil
      end
    end
  end

  # @doc ~S"""
  # Finds the `apps` "folder" depends on.

  # ## Examples

  #     iex> alias Dependents.Tree.Parser
  #     iex> projects = "c:/Users/Ray/Documents/ex_dev/projects"
  #     iex> folder = "dependents_tree"
  #     iex> path = "#{projects}/#{folder}/deps_tree.dot"
  #     iex> folders = ["dependents_tree", "io_ansi_table", "io_ansi_plus",
  #     ...>   "file_only_logger", "log_reset", "map_sorter", "persist_config"]
  #     iex> Parser.path_to_map({path, folder},folders)
  #     %{
  #       dependents_tree: [],
  #       io_ansi_table: [:dependents_tree],
  #       persist_config: [:dependents_tree]
  #     }
  # """
  @spec path_to_map({Path.t(), String.t()}, [String.t()]) :: %{app => [dep]}
  defp path_to_map({path, folder}, folders) do
    for line <- File.stream!(path), into: %{} do
      with [app, dep] <- line |> String.split("->") |> Enum.map(&String.trim/1),
           [_full, app] <- Regex.run(~r|^"(\w+)"$|, app),
           true <- app == folder,
           [_full, dep] <- Regex.run(~r|^"(\w+)" \[.+\]$|, dep),
           true <- app in folders and dep in folders do
        {String.to_atom(dep), [String.to_atom(folder)]}
      else
        _non_matched -> {String.to_atom(folder), []}
      end
    end
  end
end
