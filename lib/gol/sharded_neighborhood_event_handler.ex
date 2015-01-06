defmodule GOL.ShardedNeighborhoodEventHandler do
  use GenEvent
  alias GOL.CellShard

  def handle_event(event, {cell_shard} = state) do
    translate_to_command(event, cell_shard)
    {:ok, state}
  end

  defp translate_to_command(event, cell_shard) do
    # we should look at elem(event, 2) to filter for the cell_shard index, but only the relevant handler is registered anyway
    case event do
      {:cells_considered, _shard, number} -> CellShard.register_evolved_number cell_shard, number
      {:cell, _shard, position, life} -> CellShard.register_evolved_cell cell_shard, position, life
    end
  end
end
