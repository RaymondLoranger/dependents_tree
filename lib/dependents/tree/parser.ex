defmodule Dependents.Tree.Parser do
  @typedoc "Application"
  @type app :: Application.app()

  @typedoc "Dependent (not dependency)"
  @type dep :: Application.app()

  # mix deps.tree --format dot
  @cwd File.cwd!()
  @folder_regex ~r|^.+/(\w+)/deps_tree.dot$|
  @glob @cwd |> Path.join("../*/deps_tree.dot") |> Path.expand()

  @spec dependents_tree :: tree :: %{app => [dep]}
  def dependents_tree do
    paths = paths(@glob)
    folders = folders(paths)

    paths
    |> Enum.zip(folders)
    |> Enum.map(&path_to_map(&1, folders))
    |> Enum.reduce(%{}, &merge_maps/2)
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
    @cwd
    |> Path.join("/../#{app}/mix.exs")
    |> Path.expand()
    |> File.read!()
  end

  @spec paths(Path.t()) :: [Path.t()]
  defp paths(glob), do: Path.wildcard(glob)

  @spec folders([Path.t()]) :: [String.t()]
  defp folders(paths) do
    for path <- paths do
      folder(path)
    end
  end

  @spec folder(Path.t()) :: String.t()
  defp folder(path) do
    [_full, folder] = Regex.run(@folder_regex, path)
    folder
  end

  @spec path_to_map({Path.t(), String.t()}, [String.t()]) :: map
  defp path_to_map({path, folder}, folders) do
    for line <- File.stream!(path) do
      with [app, dep] <- line |> String.split("->") |> Enum.map(&String.trim/1),
           [_full, app] <- Regex.run(~r|^"(\w+)"$|, app),
           true <- app == folder,
           [_full, dep] <- Regex.run(~r|^"(\w+)" \[.+\]$|, dep),
           true <- app in folders and dep in folders do
        {String.to_atom(dep), [String.to_atom(folder)]}
      else
        _non_matched_value -> {String.to_atom(folder), []}
      end
    end
    |> Map.new()
  end

  @spec merge_maps(map, map) :: map
  defp merge_maps(map, acc), do: Map.merge(acc, map, &dup_key/3)

  @spec dup_key(atom, list, list) :: list
  defp dup_key(_key, val1, val2), do: val1 ++ val2
end
