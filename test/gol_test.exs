defmodule GOLTest do
  use ExUnit.Case
  alias GOL.ShardedCellEventHandler
  alias GOL.ShardedNeighborhoodEventHandler
  alias GOL.ShardIndex
  alias GOL.Position
  alias GOL.CellShard
  alias GOL.NeighborhoodShard
  alias GOL.Facade

  test "a bar rotates" do
    first_generation = Facade.empty_generation 4
    cell_shards = Map.values(first_generation)
    # 2nd row
    # TODO: build a Facade to route the cell to the correct shard during initialization
    Facade.populate_alive_cell first_generation, Position.xy(1, 0)
    Facade.populate_alive_cell first_generation, Position.xy(1, 1)
    Facade.populate_alive_cell first_generation, Position.xy(1, 2)

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

    second_generation = for related_neighborhood_shard <- neighborhood_shards, into: %{} do
      {:ok, manager} = GenEvent.start_link
      shard_index = NeighborhoodShard.shard_index(related_neighborhood_shard)
      {:ok, cell_shard} = CellShard.start_link manager, 2, shard_index
      NeighborhoodShard.attach_event_handler(
        related_neighborhood_shard,
        {ShardedNeighborhoodEventHandler, make_ref()},
        {cell_shard}
      )
      {shard_index, cell_shard}
    end
 
    Facade.evolve first_generation

    # Inspect second_generation
    IO.inspect Facade.alive second_generation
  end
end
