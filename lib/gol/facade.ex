defmodule GOL.Facade do
  alias GOL.ShardIndex
  alias GOL.CellShard

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
    GOL.Facade.each_shard generation, fn shard -> CellShard.evolve generation end
  end

  def each_shard(generation, target) do
    Map.values(generation) |>
    Enum.map(target)
  end
end
