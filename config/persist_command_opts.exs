import Config

config :dependents_tree,
  parsing_options: [
    strict: [all: :boolean, help: :boolean],
    aliases: [a: :all, h: :help]
  ]
