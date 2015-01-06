defmodule GOL.ShardedCellEventHandler do
  use GenEvent
  alias GOL.NeighborhoodShard

  def handle_event(event, {shard_index, neighborhood_shard} = state) do
    translate_to_command(event, shard_index, neighborhood_shard)
    {:ok, state}
  end

  defp translate_to_command(event, shard_index, neighborhood_shard) do
    if elem(event, 1) == shard_index do
      case event do
        {:neighborhood_needed_number, _, number} ->
          NeighborhoodShard.number_will_be neighborhood_shard, number
        {:neighborhood_needed, _, center, source} -> NeighborhoodShard.needed_in neighborhood_shard, center, source
      end
    end
  end
end
