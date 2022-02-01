import Config

config :elixir, ansi_enabled: true

config :dependents_tree,
  project_dir: System.get_env("PROJEX_DIR") |> Path.expand()
