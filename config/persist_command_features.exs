import Config

config :dependents_tree,
  aliases: [
    h: :help,
    a: :all
  ]

config :dependents_tree,
  default_switches: [
    help: false,
    all: false
  ]

config :dependents_tree,
  help_attrs: %{
    arg: :light_cyan,
    command: :light_yellow,
    normal: :reset,
    section: :light_green,
    switch: :light_yellow,
    value: :light_magenta
  }

config :dependents_tree,
  strict: [
    help: :boolean,
    all: :boolean
  ]
