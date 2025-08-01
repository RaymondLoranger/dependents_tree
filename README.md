# Dependents Tree

Writes a list of local apps to `:stdio` after ordering them topologically.

These local apps should be under some _projects directory_
and environment variable `PROJEX_DIR` should be set to it.

Only projects containing file `deps_tree.dot` (created by
`mix deps.tree --format dot`) will be considered.
Each project's root directory must match its underlying app name.
For instance, directory `dependents_tree` for app `:dependents_tree`.
Does not support umbrella projects.

The dependencies of an app are specified in the `mix.exs` file.
The _dependents_ of an app are those apps using it as a dependency.

Allows to update local interdependent apps in a topological order.
In other words, if a given app is changed, what other apps become outdated
(directly or _indirectly_) and in what order should they be updated so that,
at the end, they are all up-to-date.

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
  - `deps_tree <app_dir>`
