defmodule Dependents.Tree.CLI do
  @moduledoc """
  Parses the command line and prints a dependents tree table.
  """

  use PersistConfig

  alias Dependents.Tree.Help
  alias Dependents.Tree
  alias IO.ANSI.Table

  @type app :: Application.app()
  @type parsed :: {app} | :all | :help

  @aliases get_env(:aliases)
  @cwd File.cwd!()
  @strict get_env(:strict)
  @switches get_env(:default_switches)
  @table_spec get_env(:table_spec)

  @doc """
  Parses the command line and prints a dependents tree table.

  ## Parameters

    - `argv` - command line arguments (list)
  """
  @spec main([String.t()]) :: :ok | no_return
  def main(argv) do
    case parse(argv) do
      {app} ->
        if project?(app),
          do: Tree.to_maps(app) |> Table.write(@table_spec),
          else: Help.show_help()

      :all ->
        Tree.to_maps(:*) |> Table.write(@table_spec)

      :help ->
        Help.show_help()
    end
  end

  ## Private functions

  @spec project?(app) :: boolean
  defp project?(app), do: Path.join(@cwd, "../#{app}/mix.exs") |> File.exists?()

  # @doc """
  # Parses `argv` (command line arguments).

  # `argv` can be "-h" or "--help", which returns :help.
  # Otherwise it may contain an app (folder) or `--all`.
  # If no app is given, the current app (folder) is assumed.

  # ## Parameters

  #   - `argv` - command line arguments (list)

  # ## Switches

  #   - `-h` or `--help` - for help
  #   - `-a` or `--all`  - to print the dependents tree of all apps

  # ## Examples

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.parse(["--all"])
  #     :all

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.parse(["-a", "file_only_logger"])
  #     :all

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.parse(["-h"])
  #     :help

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.parse(["-h", "file_only_logger"])
  #     :help

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.parse([])
  #     {:dependents_tree}

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.parse(["file_only_logger"])
  #     {:file_only_logger}
  # """
  @spec parse([String.t()]) :: parsed
  defp parse(argv) do
    argv
    |> OptionParser.parse(strict: @strict, aliases: @aliases)
    |> to_parsed()
  end

  # @doc """
  # Converts the output of `OptionParser.parse/2` to `parsed`.

  # ## Examples

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_parsed({[all: true], [], []})
  #     :all

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_parsed({[all: true], ["file_only_logger"], []})
  #     :all

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_parsed({[help: true], [], []})
  #     :help

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_parsed({[help: true], ["file_only_logger"], []})
  #     :help

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_parsed({[], [], []})
  #     {:dependents_tree}

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_parsed({[], ["file_only_logger"], []})
  #     {:file_only_logger}
  # """
  @spec to_parsed({Keyword.t(), [String.t()], [tuple]}) :: parsed
  defp to_parsed({switches, args, []}) do
    with {app} <- to_tuple(args),
         %{help: false, all: false} <-
           Map.merge(Map.new(@switches), Map.new(switches)) do
      {app}
    else
      %{help: false, all: true} -> :all
      _ -> :help
    end
  end

  defp to_parsed(_), do: :help

  # @doc """
  # Converts `args` to a tuple or `:error`.

  # ## Examples

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_tuple([])
  #     {:dependents_tree}

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_tuple(["file_only_logger"])
  #     {:file_only_logger}

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_tuple(["?"])
  #     {:"?"}

  #     iex> alias Dependents.Tree.CLI
  #     iex> CLI.to_tuple([:all])
  #     :error
  # """
  @spec to_tuple([String.t()]) :: {app} | :error
  defp to_tuple([] = _args) do
    {Path.expand(".") |> Path.basename() |> String.to_atom()}
  end

  defp to_tuple([app] = _args) when is_binary(app), do: {String.to_atom(app)}
  defp to_tuple(_), do: :error
end
