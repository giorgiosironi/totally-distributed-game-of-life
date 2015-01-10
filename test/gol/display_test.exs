defmodule GOL.DisplayTest do
  use ExUnit.Case
  alias GOL.Facade
  alias GOL.Position
  alias GOL.Display

  test "displays a window over a generation on the terminal" do
    generation = Facade.empty_generation
    Facade.populate_alive_cell generation, Position.xy(1, 0)
    Facade.populate_alive_cell generation, Position.xy(1, 1)
    Facade.populate_alive_cell generation, Position.xy(1, 2)
    
    assert " X  \n"
        <> " X  \n"
        <> " X  \n"
        <> "    \n"
        == Display.window Position.xy(0, 0), Position.xy(3, 3), generation
    
  end
end
