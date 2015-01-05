defmodule GOL.NeighborhoodShard do
  use GenServer

  def start_link(neighborhood_events, generation, shard_index, opts \\ []) do
    GenServer.start_link(
      __MODULE__, 
      %{
        neighborhood_events: neighborhood_events,
        generation: generation,
        shard_index: shard_index
      },
      opts
    )
  end

  def number_will_be(shard, number) do
    GenServer.call(shard, {:number_will_be, number})
  end

  def needed_in(shard, position) do
    GenServer.call(shard, {:needed_in, position})
  end

  def handle_call({:number_will_be, number}, _from, state) do
    {:reply, nil, state}
  end

  def handle_call({:needed_in, position}, _from, state) do
    {:reply, nil, state}
  end
end
