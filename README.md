# Dependents Tree

Writes local apps to "stdio" after ordering them topologically.

These local apps should be under some _projects directory_
and environment variable `PROJEX_DIR` should be set to it.

Only projects containing file `deps_tree.dot` (created by
`mix deps.tree --format dot`) will be considered.
Each project's root directory must match its underlying app name.
For instance, dir `dependents_tree` for app `:dependents_tree`.
Does not support umbrella projects.

Allows to update local interdependent apps in a topological order.
In other words, if a given app changes, what other dependent apps
become outdated and in what order must they be updated themselves.

## Usage

To use `Dependents Tree` locally, run these commands:

  - `set PROJEX_DIR=<elixir_projects_dir>`
  - `git clone https://github.com/RaymondLoranger/dependents_tree`
  - `cd dependents_tree`
  - `mix deps.get`
  - `mix escript.build`
  - `mix escript.install`

You can now run the application like so:

  - `deps_tree --help`
  - `deps_tree --all`
  - `deps_tree <some_app>`
