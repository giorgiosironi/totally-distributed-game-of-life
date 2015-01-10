generation = GOL.Facade.empty_generation 4
GOL.Facade.populate_alive_cell generation, GOL.Position.xy(1, 0)
GOL.Facade.populate_alive_cell generation, GOL.Position.xy(1, 1)
GOL.Facade.populate_alive_cell generation, GOL.Position.xy(1, 2)

defmodule GOL.CLI do
  def evolve_and_display current_generation do
    IO.puts "\x1B[2J"
    IO.puts GOL.Display.window(GOL.Position.xy(0, 0), GOL.Position.xy(3, 3), current_generation)
    current_generation = GOL.Facade.evolve current_generation
    :timer.sleep 1000
    evolve_and_display(current_generation)
  end
end

GOL.CLI.evolve_and_display generation
