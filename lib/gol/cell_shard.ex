defmodule GOL.CellShard do
  use GenServer

  def start_link(generation, shard_index, args \\ []) do
    GenServer.start_link(__MODULE__, %{:generation => generation, :shard_index => shard_index}, args)
  end
end
