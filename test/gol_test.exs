defmodule GOLTest do
  use ExUnit.Case
  alias GOL.ShardedCellEventHandler
  alias GOL.ShardIndex
  alias GOL.Position
  alias GOL.CellShard
  alias GOL.NeighborhoodShard

  test "a bar rotates" do
    cell_shards = for i <- 1..4 do
      {:ok, manager} = GenEvent.start_link
      {:ok, shard} = CellShard.start_link manager, 1, ShardIndex.from "#{i}in4"
      shard
    end
    # 2nd row
    # TODO: build a Facade to route the cell to the correct shard during initialization
    CellShard.add_alive_cell hd(tl(cell_shards)), Position.xy(1, 0)
    CellShard.add_alive_cell hd(tl(cell_shards)), Position.xy(1, 1)
    CellShard.add_alive_cell hd(tl(cell_shards)), Position.xy(1, 2)

    neighborhood_shards = for i <- 1..4 do
      {:ok, manager} = GenEvent.start_link
      shard_index = ShardIndex.from "#{i}in4"
      {:ok, shard} = NeighborhoodShard.start_link manager, 2, shard_index
      for cell_shard <- cell_shards do
        CellShard.attach_event_handler(
          cell_shard,
          ShardedCellEventHandler,
          {shard_index, shard}
        )
      end
      shard
    end

    for neighborhood_shard <- neighborhood_shards do
      NeighborhoodShard.attach_event_handler(
        neighborhood_shard,
        ShardedNeighborhoodEventHandler,
        {}
      )
    end
 
    CellShard.evolve hd(tl(cell_shards))
  end
end
