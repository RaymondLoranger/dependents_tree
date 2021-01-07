defmodule Dependents.Tree.Help do
  use PersistConfig

  @escript Mix.Project.config()[:escript][:name]
  @help_attrs get_env(:help_attrs)

  @spec show_help() :: no_return
  def show_help() do
    # Examples of usage on Windows:
    #   escript deps_tree --help
    #   escript deps_tree file_only_logger
    #   escript deps_tree
    #   escript deps_tree --all
    # Examples of usage on macOS:
    #   ./deps_tree -a
    {types, texts} =
      case :os.type() do
        {:win32, _} ->
          {[:section, :normal, :command, :normal],
           ["usage:", " ", "escript", " #{@escript}"]}

        {:unix, _} ->
          {[:section, :normal], ["usage:", " ./#{@escript}"]}
      end

    filler = String.duplicate(" ", Enum.join(texts) |> String.length())
    prefix = help_format(types, texts)
    item_help = help_format([:switch], ["[(-h | --help)]"])
    item_all = help_format([:switch], ["[(-a | --all)]"])
    item_app = help_format([:arg], ["<app>"])
    item_where = help_format([:section], ["where:"])

    item_default_app =
      help_format([:normal, :arg, :normal, :value], [
        "  - default ",
        "<app>",
        " is ",
        "the current app (folder)"
      ])

    IO.write("""
    #{prefix} #{item_help}
    #{filler} #{item_all}
    #{filler} #{item_app}
    #{item_where}
    #{item_default_app}
    """)

    System.stop(0)
  end

  ## Private functions

  @spec help_format([atom], [String.t()]) :: IO.chardata()
  defp help_format(types, texts) do
    types
    |> Enum.map(&@help_attrs[&1])
    |> Enum.zip(texts)
    |> Enum.map(&Tuple.to_list/1)
    |> IO.ANSI.format()
  end
end
