defmodule GOL.CLI do
  def evolve_and_display current_generation do
    evolve_and_display current_generation, 10
  end

  def evolve_and_display current_generation, window_size do
    evolve_and_display current_generation, window_size, 1000
  end

  def evolve_and_display current_generation, window_size, evolution_time do
    IO.puts "\x1B[2J"
    IO.puts GOL.Display.window(GOL.Position.xy(0, 0), GOL.Position.xy(window_size, window_size), current_generation)
    current_generation = GOL.Facade.evolve current_generation
    :timer.sleep evolution_time
    evolve_and_display(current_generation, window_size, evolution_time)
  end
end
