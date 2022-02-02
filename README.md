# Dependents Tree

Writes local apps to "stdio" after sorting them topologically.

Change management app topologically listing interdependent apps residing in a local project directory set by environment variable `PROJEX_DIR`.

Only projects containing file `deps_tree.dot` will be considered.
To generate the DOT graph file, run `mix deps.tree --format dot`.
Each project's root directory must match the app name it contains.
For instance, dir `dependents_tree` for app `:dependents_tree`.
Does not support umbrella projects.

Allows to update local interdependent apps in a proper topological order.

## Usage

To use `Dependents Tree` locally, run these commands:

  - `set PROJEX_DIR="<elixir_project_dir>"`
  - `git clone https://github.com/RaymondLoranger/dependents_tree`
  - `cd dependent_tree`
  - `mix deps.get`
  - `mix escript.build`
  - `mix escript.install`

You can now run the application like so:

  - `deps_tree --help`
  - `deps_tree --all`
  - `deps_tree <some_app>`
