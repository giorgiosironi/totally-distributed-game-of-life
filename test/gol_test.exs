defmodule GOLTest do
  use ExUnit.Case
  alias GOL.Position
  alias GOL.Facade

  test "a bar rotates" do
    first_generation = Facade.empty_generation 4
    Facade.populate_alive_cell first_generation, Position.xy(1, 0)
    Facade.populate_alive_cell first_generation, Position.xy(1, 1)
    Facade.populate_alive_cell first_generation, Position.xy(1, 2)
 
    second_generation = Facade.evolve first_generation
    assert [Position.xy(0, 1), 
            Position.xy(1, 1), 
            Position.xy(2, 1)] == Facade.alive second_generation

    third_generation = Facade.evolve second_generation
    assert [Position.xy(1, 0), 
            Position.xy(1, 1), 
            Position.xy(1, 2)] == Facade.alive third_generation
  end

  test "a block stays still" do

    first_generation = Facade.empty_generation 4
    Facade.populate_alive_cell first_generation, Position.xy(1, 1)
    Facade.populate_alive_cell first_generation, Position.xy(1, 2)
    Facade.populate_alive_cell first_generation, Position.xy(2, 1)
    Facade.populate_alive_cell first_generation, Position.xy(2, 2)
 
    second_generation = Facade.evolve first_generation
    assert [Position.xy(1, 1), 
            Position.xy(1, 2), 
            Position.xy(2, 1), 
            Position.xy(2, 2)] == Facade.alive second_generation
  end
end
