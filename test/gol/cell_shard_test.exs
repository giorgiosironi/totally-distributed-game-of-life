defmodule GOL.CellShardTest do
  use ExUnit.Case
  alias GOL.CellShard
  alias GOL.ShardIndex

  test "tells all cells to evolve" do
    {:ok, shard} = CellShard.start_link 1, ShardIndex.from "0in4"
  end
end
