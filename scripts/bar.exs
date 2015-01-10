generation = GOL.Facade.empty_generation 4
GOL.Facade.populate_alive_cell generation, GOL.Position.xy(1, 0)
GOL.Facade.populate_alive_cell generation, GOL.Position.xy(1, 1)
GOL.Facade.populate_alive_cell generation, GOL.Position.xy(1, 2)

GOL.CLI.evolve_and_display generation
