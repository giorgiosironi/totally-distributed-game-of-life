defmodule GOLTest do
  use ExUnit.Case
  alias GOL.ShardedCellEventHandler
  alias GOL.ShardedNeighborhoodEventHandler
  alias GOL.ShardIndex
  alias GOL.Position
  alias GOL.CellShard
  alias GOL.NeighborhoodShard

  test "a bar rotates" do
    cell_shards = for i <- 0..3 do
      {:ok, manager} = GenEvent.start_link
      {:ok, shard} = CellShard.start_link manager, 1, ShardIndex.from "#{i}in4"
      shard
    end
    # 2nd row
    # TODO: build a Facade to route the cell to the correct shard during initialization
    CellShard.populate_alive_cell hd(tl(cell_shards)), Position.xy(1, 0)
    CellShard.populate_alive_cell hd(tl(cell_shards)), Position.xy(1, 1)
    CellShard.populate_alive_cell hd(tl(cell_shards)), Position.xy(1, 2)

    neighborhood_shards = for i <- 0..3 do
      {:ok, manager} = GenEvent.start_link
      shard_index = ShardIndex.from "#{i}in4"
      {:ok, shard} = NeighborhoodShard.start_link manager, 2, shard_index
      for cell_shard <- cell_shards do
        CellShard.attach_event_handler(
          cell_shard,
          {ShardedCellEventHandler, make_ref()},
          {shard_index, shard}
        )
      end
      shard
    end

    second_generation_cell_shards = for related_neighborhood_shard <- neighborhood_shards do
      {:ok, manager} = GenEvent.start_link
      {:ok, cell_shard} = CellShard.start_link manager, 2, NeighborhoodShard.shard_index(related_neighborhood_shard)
      NeighborhoodShard.attach_event_handler(
        related_neighborhood_shard,
        {ShardedNeighborhoodEventHandler, make_ref()},
        {cell_shard}
      )
      cell_shard
    end
 
    for cell_shard <- cell_shards do
      CellShard.evolve cell_shard
    end

    # Inspect second_generation_cell_shards
    for second_cell_shard <- second_generation_cell_shards do
      IO.inspect CellShard.alive(second_cell_shard)
    end
  end
end
