defmodule GOL.CellShard do
  use GenServer
  alias GOL.Cell
  alias GOL.ShardIndex

  def start_link(cell_events, generation, shard_index, args \\ []) do
    GenServer.start_link(
      __MODULE__, 
      %{
        :cell_events => cell_events,
        :generation => generation,
        :shard_index => shard_index,
        :cells => []
      },
      args
    )
  end

  def add_alive_cell(shard, position) do
    GenServer.call(shard, {:add_alive_cell, position})
  end

  def alive(shard) do
    GenServer.call(shard, {:alive})
  end

  # TODO: docblocks
  def evolve(shard) do
    GenServer.call(shard, {:evolve})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:add_alive_cell, position}, _from, state) do
    {:ok, cell} = Cell.start_link position
    {:reply,
     nil,
     Map.update!(state, :cells, fn list ->
       list ++ [cell]
     end)}
  end

  def handle_call({:alive}, _from, state) do
    # TODO: parallelize in some way
    positions = for c <- state.cells do
      Cell.position c
    end
    {:reply, positions, state}
  end

  def handle_call({:evolve}, _from, state) do
    for_all_shards(state,
      fn shard_index ->
        emit_event(state, {
          :neighborhood_needed_number,
          shard_index,
          Enum.map(state.cells, fn c ->
            Cell.neighborhood_needed_number c, shard_index
          end) |>
          Enum.reduce(fn elem, total ->
            total + elem
          end)
        })
      end
    )
    for_all_shards(state,
      fn shard_index ->
        Enum.each(state.cells, fn source ->
          Cell.neighborhoods source, shard_index, fn center, source ->
            emit_event(state, {
              :neighborhood_needed,
              shard_index,
              center,
              source
            })
          end
        end)
      end
    )
    {:reply, nil, state}
  end

  defp for_all_shards(state, what_to_do) do
    Enum.each(
      ShardIndex.all(state.shard_index),
      what_to_do
    )
  end

  defp emit_event(state, event) do
    GenEvent.sync_notify state.cell_events, event
  end
end
