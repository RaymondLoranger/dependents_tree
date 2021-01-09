import Config

config :elixir, ansi_enabled: true

config :dependents_tree,
  project_dir: File.cwd!() |> Path.join("..") |> Path.expand()
