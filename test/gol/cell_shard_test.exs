defmodule GOL.CellShardTest do
  use ExUnit.Case
  alias GOL.CellShard
  alias GOL.Position
  alias GOL.ShardIndex

  test "tells all cells to evolve" do
    {:ok, shard} = CellShard.start_link 1, ShardIndex.from "0in4"
    CellShard.add_alive_cell shard, Position.xy(5, 6)
    assert [Position.xy(5, 6)] == CellShard.alive shard
  end
end
