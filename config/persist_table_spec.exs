import Config

alias IO.ANSI.Table.Spec

headers = [
  :rank,
  :chunk,
  :ver,
  :hex,
  :app,
  :deps,
  :dependent_1,
  :dependent_2,
  :dependent_3,
  :dependent_4
]

options = [
  align_specs: [center: :hex],
  bell: true,
  count: 999,
  header_fixes: %{~r/^hex$/i => "Hex?"},
  sort_specs: [:rank, :chunk, :app],
  margins: [top: 0, bottom: 0, left: 0],
  style: :plain
]

config :dependents_tree, table_spec: Spec.new(headers, options) |> Spec.extend()
