defmodule Dependents.Tree.Help do
  @moduledoc """
  Prints info on the escript command's usage and syntax.
  """

  use PersistConfig

  @escript Mix.Project.config()[:escript][:name]
  @help_attrs get_env(:help_attrs)

  @doc """
  Prints info on the escript command's usage and syntax.
  """
  @spec show_help() :: :ok
  def show_help() do
    # Examples of usage:
    #   deps_tree --help
    #   deps_tree file_only_logger
    #   deps_tree
    #   deps_tree .
    #   deps_tree --all
    #   deps_tree -a
    texts = ["usage:", " #{@escript}"]
    filler = String.pad_leading("", Enum.join(texts) |> String.length())
    prefix = help_format([:section, :normal], texts)
    item_help = help_format([:switch], ["[(-h | --help)]"])
    item_all = help_format([:switch], ["[(-a | --all)]"])
    item_app = help_format([:arg], ["<app_dir>"])
    item_where = help_format([:section], ["where:"])

    item_default_app =
      help_format([:normal, :arg, :normal, :value], [
        "  - default ",
        "<app_dir>",
        " is ",
        "the current (app) directory"
      ])

    IO.write("""
    #{prefix} #{item_help}
    #{filler} #{item_all}
    #{filler} #{item_app}
    #{item_where}
    #{item_default_app}
    """)
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
