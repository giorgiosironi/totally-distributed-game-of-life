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
end
