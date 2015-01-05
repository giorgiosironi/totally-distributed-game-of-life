defmodule GOL.CellShardTest do
  use ExUnit.Case
  alias GOL.CellShard

  test "tells all cells to evolve" do
    {:ok, shard} = CellShard.start_link 1, "1of4"
  end
end
