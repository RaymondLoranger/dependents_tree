defmodule Dependents.Tree.MixProject do
  use Mix.Project

  def project do
    [
      app: :dependents_tree,
      version: "0.1.24",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "Dependents Tree",
      source_url: source_url(),
      description: description(),
      package: package(),
      escript: escript(),
      deps: deps(),
      # See Dependents.Tree.CLI.main/1...
      dialyzer: [plt_add_apps: [:io_ansi_table]]
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/dependents_tree"
  end

  defp description do
    """
    Writes a list of local apps to "stdio" after ordering them topologically.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "config/persist*.exs"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # Only using the `IO.ANSI.Table.write/2` function.
      included_applications: [:io_ansi_table],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:io_ansi_table, "~> 1.0"},
      {:persist_config, "~> 0.4", runtime: false}
    ]
  end

  defp escript do
    [
      main_module: Dependents.Tree.CLI,
      # `:deps` would collide with folder `deps`.
      name: :deps_tree
    ]
  end
end
