generation = GOL.Facade.empty_generation 4
size = 30
:random.seed(:os.timestamp)
alive_cells = :erlang.trunc(size * size * 0.4)
for i <- 1..alive_cells do
  x = :random.uniform(size + 1) - 1
  y = :random.uniform(size + 1) - 1
  GOL.Facade.populate_alive_cell generation, GOL.Position.xy(x, y)
end

GOL.CLI.evolve_and_display generation, 30, 500
