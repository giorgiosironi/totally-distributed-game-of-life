defmodule GOL.ShardedCellEventHandler do
  use GenEvent
  alias GOL.NeighborhoodShard

  def handle_event(event, {shard_index, neighborhood_shard} = state) do
    IO.inspect(event)
    translate_to_command(event, shard_index, neighborhood_shard)
    {:ok, state}
  end

  defp translate_to_command(event, shard_index, neighborhood_shard) do
    case event do
      {:neighborhood_needed_number, shard_index, number} -> NeighborhoodShard.number_will_be neighborhood_shard, number
      {:neighborhood_needed, shard_index, center, source} -> NeighborhoodShard.needed_in neighborhood_shard, center, source
    end
  end
end
