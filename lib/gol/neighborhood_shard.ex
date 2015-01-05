defmodule GOL.NeighborhoodShard do
  use GenServer
  alias GOL.Neighborhood

  def start_link(neighborhood_events, generation, shard_index, opts \\ []) do
    GenServer.start_link(
      __MODULE__, 
      %{
        neighborhood_events: neighborhood_events,
        generation: generation,
        shard_index: shard_index,
        totals_neighborhoods: [],
        total_neighborhoods_needed_received: 0,
        neighborhoods: %{}
      },
      opts
    )
  end

  def number_will_be(shard, number) do
    GenServer.call(shard, {:number_will_be, number})
  end

  def needed_in(shard, position, source) do
    GenServer.call(shard, {:needed_in, position, source})
  end

  def handle_call({:number_will_be, number}, _from, state) do
    state = Map.update!(state, :totals_neighborhoods, fn totals ->
      totals ++ [number]
    end)
    check_completion(state)
    {:reply, nil, state}
  end

  def handle_call({:needed_in, position, source}, _from, state) do
    state = Map.update!(state, :neighborhoods, fn neighborhoods ->
      if Map.has_key?(neighborhoods, position) do
        neighborhood = Map.get(neighborhoods, position)
      else
        {:ok, neighborhood} = Neighborhood.start_link position
        neighborhoods = Map.put(neighborhoods, position, neighborhood)
      end
      Neighborhood.one_cell_is_alive neighborhood, source
      neighborhoods
    end)
    state = Map.update!(state, :total_neighborhoods_needed_received, fn total -> total + 1 end)
    check_completion(state)
    {:reply, nil, state}
  end

  defp check_completion(state) do
    if state.shard_index.total == Enum.count(state.totals_neighborhoods)
    && Enum.reduce(state.totals_neighborhoods, fn a, b -> a + b end) == state.total_neighborhoods_needed_received do
      # TODO: total_neighborhoods_needed_received is incorrect, we should use the number of neighborhoods. Add a relevant test
      GenEvent.sync_notify state.neighborhood_events, {:cells_considered, state.shard_index, Enum.count(state.neighborhoods)}
      Map.values(state.neighborhoods) |>
      Enum.each(fn neighborhood ->
        Neighborhood.to_new_cell neighborhood, fn center, life -> 
          GenEvent.sync_notify state.neighborhood_events, {:cell, state.shard_index, center, life} 
        end
      end)
    end
  end

end
