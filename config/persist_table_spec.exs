import Config

alias IO.ANSI.Table.Spec

config :dependents_tree,
  table_spec:
    Spec.new(
      [
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
      ],
      align_specs: [center: :hex],
      bell: true,
      count: 999,
      header_fixes: %{~r/^hex$/i => "Hex?"},
      margins: [top: 0, left: 0, bottom: 0],
      sort_specs: [:rank, :chunk, :app],
      style: :plain
    )
    |> Spec.extend()
