defmodule Dependents.Tree.CLI do
  @moduledoc """
  Parses the command line and prints a `Dependents.Tree` table.
  """

  use PersistConfig

  alias Dependents.Tree.Help
  alias Dependents.Tree
  alias IO.ANSI.Table

  @options get_env(:parsing_options)
  @table_spec get_env(:table_spec)

  @doc """
  Parses the command line and prints a `Dependents.Tree` table.

  The dependencies of an app are specified in the `mix.exs` file.
  The _dependents_ of an app are those apps using it as a dependency.

  `argv` can be "-h" or "--help", which prints info on the command's
  usage and syntax. Otherwise it is an apps's directory, to list all
  direct and indirect _dependents_ of that app. To list dependents
  of all apps, specify switch `--all`.

  ## Parameters

    - `argv` - command line arguments (list)

  ## Switches

    - `-h` or `--help` - for help
    - `-a` or `--all`  - to list dependents of all apps
  """
  @spec main(OptionParser.argv()) :: :ok
  def main(argv) do
    case OptionParser.parse(argv, @options) do
      {[all: true], [], []} -> Table.write(@table_spec, Tree.to_maps(:*))
      {[help: true], [], []} -> Help.show_help()
      {[], [dir], []} -> maybe_write_table(dir)
      {[], [], []} -> maybe_write_table(".")
      _else -> Help.show_help()
    end
  end

  ## Private functions

  @spec maybe_write_table(Path.t()) :: :ok
  defp maybe_write_table(dir) do
    app =
      dir
      # In case of any trailing separator(s) for example...
      |> Path.basename()
      |> Path.expand()
      |> Path.basename()
      |> String.to_atom()

    maybe_write_table(app, project?(app))
  end

  @spec maybe_write_table(Tree.app(), boolean) :: :ok
  defp maybe_write_table(app, _project? = true) do
    Table.write(@table_spec, Tree.to_maps(app))
  end

  defp maybe_write_table(_app, false) do
    Help.show_help()
  end

  @spec project?(Tree.app()) :: boolean
  defp project?(app) do
    File.exists?("#{Tree.projects_dir()}/#{app}/mix.exs")
  end
end
