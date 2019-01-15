defmodule Dependents.Tree.CLI do
  @moduledoc """
  Parses the command line and prints a dependents tree table.
  """

  use PersistConfig

  alias Dependents.Tree
  alias Dependents.Tree.Help

  @type app :: Application.app()
  @type parsed :: {app} | :all | :help

  @aliases Application.get_env(@app, :aliases)
  @cwd File.cwd!()
  @strict Application.get_env(@app, :strict)
  @switches Application.get_env(@app, :default_switches)

  @doc """
  Parses and processes `argv` (command line arguments).

  ## Parameters

    - `argv` - command line arguments (list)
  """
  @spec main([String.t()]) :: :ok | no_return
  def main(argv) do
    with {app} when is_atom(app) <- parse(argv),
         true <- @cwd |> Path.join("../#{app}/mix.exs") |> File.exists?() do
      Tree.print(app)
    else
      false -> Help.show_help()
      :help -> Help.show_help()
      :all -> Tree.print(:*)
    end
  end

  @doc ~S"""
  Parses `argv` (command line arguments).

  `argv` can be ["-h"] or ["--help"], which returns :help.
  Otherwise it may contain an app or `--all`.
  If no app is given, the current app (folder) is assumed.

  ## Parameters

    - `argv` - command line arguments (list)

  ## Switches

    - `-h` or `--help` - for help
    - `-a` or `--all`  - to print the dependents tree of all apps

  ## Examples

      iex> alias Dependents.Tree.CLI
      iex> CLI.parse(["-h"])
      :help

      iex> alias Dependents.Tree.CLI
      iex> CLI.parse(["file_only_logger"])
      {:file_only_logger}

      iex> alias Dependents.Tree.CLI
      iex> CLI.parse(["file_only_logger\\"])
      {:file_only_logger}

      iex> alias Dependents.Tree.CLI
      iex> CLI.parse(["file_only_logger/"])
      {:file_only_logger}

      iex> alias Dependents.Tree.CLI
      iex> CLI.parse(["--all"])
      :all
  """
  @spec parse([String.t()]) :: parsed
  def parse(argv) do
    argv
    |> OptionParser.parse(strict: @strict, aliases: @aliases)
    |> to_parsed()
  end

  ## Private functions

  @spec to_parsed({Keyword.t(), [String.t()], [tuple]}) :: parsed
  defp to_parsed({switches, args, []}) do
    with {app} when is_atom(app) <- to_tuple(args),
         %{help: false, all: false} <-
           Map.merge(Map.new(@switches), Map.new(switches)) do
      {app}
    else
      %{help: false, all: true} -> :all
      _ -> :help
    end
  end

  defp to_parsed(_), do: :help

  @spec to_tuple([String.t()]) :: {app} | :error
  defp to_tuple([] = _args) do
    {"." |> Path.expand() |> Path.basename() |> String.to_atom()}
  end

  defp to_tuple([app] = _args) when is_binary(app) do
    # Remove any trailing separator(s)
    {app |> Path.basename() |> String.to_atom()}
  end

  defp to_tuple(_), do: :error
end
