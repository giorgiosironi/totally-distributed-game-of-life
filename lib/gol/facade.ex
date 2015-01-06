defmodule GOL.Facade do
  alias GOL.ShardIndex
  alias GOL.CellShard
  alias GOL.NeighborhoodShard
  alias GOL.ShardedCellEventHandler
  alias GOL.ShardedNeighborhoodEventHandler

  def empty_generation total_shards do
    for i <- 0..total_shards-1, into: %{} do
      {:ok, manager} = GenEvent.start_link
      shard_index = ShardIndex.from "#{i}in4"
      {:ok, shard} = CellShard.start_link manager, 1, shard_index
      {shard_index, shard}
    end
  end

  def populate_alive_cell(generation, position) do
    # TODO: duplication of position.x
    index = Map.keys(generation) |>
            Enum.find(fn shard_index ->
              ShardIndex.contains(shard_index, position.x)
            end)
    CellShard.populate_alive_cell Map.get(generation, index), position
  end

  def alive(generation) do
    Map.values(generation) |>
    Enum.flat_map(fn shard ->
      CellShard.alive shard
    end)
  end

  def evolve(generation) do

    neighborhood_shards = for i <- 0..3 do
      {:ok, manager} = GenEvent.start_link
      shard_index = ShardIndex.from "#{i}in4"
      {:ok, shard} = NeighborhoodShard.start_link manager, 2, shard_index
      for cell_shard <- Map.values(generation) do
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

    GOL.Facade.each_shard generation, fn shard -> CellShard.evolve shard end

    second_generation
  end

  def each_shard(generation, target) do
    Map.values(generation) |>
    Enum.map(target)
  end
end
