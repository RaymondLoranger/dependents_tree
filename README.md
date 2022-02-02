# Dependents Tree

Writes local apps to "stdio" after ordering them topologically.

Change management app topologically listing local apps residing
in a project directory set by environment variable `PROJEX_DIR`.

Only projects containing file `deps_tree.dot` will be considered.
To generate the DOT graph file, run `mix deps.tree --format dot`.
Each project's root directory must match the app name it contains.
For instance, dir `dependents_tree` for app `:dependents_tree`.
Does not support umbrella projects.

Allows to update local interdependent apps in a topological order.
In other words, if a given app changes, what other dependent apps
become outdated and in what order must they be updated themselves.

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
