defmodule GOL.CLI do
  def evolve_and_display current_generation do
    evolve_and_display current_generation, 1000
  end

  def evolve_and_display current_generation, evolution_time do
    IO.puts "\x1B[2J"
    IO.puts GOL.Display.window(GOL.Position.xy(0, 0), GOL.Position.xy(3, 3), current_generation)
    current_generation = GOL.Facade.evolve current_generation
    :timer.sleep evolution_time
    evolve_and_display(current_generation)
  end
end
