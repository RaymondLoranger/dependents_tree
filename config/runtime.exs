import Config

config :dependents_tree,
  project_dir: File.cwd!() |> Path.join("..") |> Path.expand()
