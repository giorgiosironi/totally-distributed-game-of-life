defmodule GOL.CellTest do
  use ExUnit.Case
  alias GOL.Cell
  alias GOL.Position
  alias GOL.ShardIndex

  test "stores its position" do
    {:ok, cell} = Cell.start_link Position.xy(4, 5)
    assert Position.xy(4, 5) == Cell.position cell
  end

  test "knows the number of neighborhood to consider for evolution" do
    {:ok, cell} = Cell.start_link Position.xy(4, 5)
    assert 9 == Cell.neighborhood_needed_number cell
  end

  test "knows the number of neighborhood to consider for evolution and that fall into a shard" do
    {:ok, cell} = Cell.start_link Position.xy(1, 1)
    assert 3 == Cell.neighborhood_needed_number cell, ShardIndex.from "0in4"
    assert 3 == Cell.neighborhood_needed_number cell, ShardIndex.from "1in4"
    assert 3 == Cell.neighborhood_needed_number cell, ShardIndex.from "2in4"
    assert 0 == Cell.neighborhood_needed_number cell, ShardIndex.from "3in4"
  end

  test "iterates over its neighborhoods " do
    {:ok, cell} = Cell.start_link Position.xy(1, 1)
    parent = self()
    Cell.neighborhoods cell, fn center, source -> send parent, {center, source} end
    own_position = Position.xy(1, 1)
    assert_receive {own_position, own_position}
  end

  test "iterates over its neighborhoods for a particular shard" do
    own_position = Position.xy(1, 1)
    {:ok, cell} = Cell.start_link own_position
    parent = self()
    Cell.neighborhoods cell, ShardIndex.from("0in4"), fn center, source -> send parent, {center, source} end
    correct_position = Position.xy(0, 1)
    assert_receive {correct_position, own_position}
  end
end
