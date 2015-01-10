defmodule GOL.FacadeTest do
  use ExUnit.Case
  alias GOL.Facade
  alias GOL.Position

  test "populates and retrieves cells from multiple shards" do
    generation = Facade.empty_generation 4
    Facade.populate_alive_cell generation, Position.xy(1, 0)
    Facade.populate_alive_cell generation, Position.xy(3, 4)
    assert [Position.xy(1, 0), Position.xy(3, 4)] == Facade.alive generation
  end

  test "tests the lifeness of a cell over the correct shard" do
    generation = Facade.empty_generation 4
    Facade.populate_alive_cell generation, Position.xy(1, 0)
    Facade.populate_alive_cell generation, Position.xy(3, 4)
    assert true == Facade.alive generation, Position.xy(1, 0)
    assert false == Facade.alive generation, Position.xy(1, 1)
  end
end
