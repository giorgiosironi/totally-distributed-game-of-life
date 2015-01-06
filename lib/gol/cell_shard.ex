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
        :cells => [],
        :registered_cells_current => 0,
        :registered_cells_expected => nil
      },
      args
    )
  end

  def populate_alive_cell(shard, position) do
    GenServer.call(shard, {:populate_alive_cell, position})
  end

  def register_evolved_cell(shard, position, life) do
    GenServer.call(shard, {:register_evolved_cell, position, life})
  end

  def register_evolved_number(shard, number) do
    GenServer.call(shard, {:register_evolved_number, number})
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

  def attach_event_handler(shard, handler, handler_state) do
    GenServer.call(shard, {:attach_event_handler, handler, handler_state})
  end

  def handle_call({:populate_alive_cell, position}, _from, state) do
    {:reply,
     nil,
     spawn_alive_cell(state, position)}
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
          Enum.reduce(0, fn elem, total ->
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

  def handle_call({:attach_event_handler, handler, handler_state}, _from, state) do
    GenEvent.add_mon_handler(state.cell_events, handler, handler_state)
    {:reply, nil, state}
  end

  def handle_call({:register_evolved_cell, position, life}, _from, state) do
    if life == :alive do
      state = spawn_alive_cell(state, position)
    end
    state = Map.update!(state, :registered_cells_current, fn number -> number + 1 end)
    {:reply, nil, state}
  end

  def handle_call({:register_evolved_number, number}, _from, state) do
    state = Map.put(state, :registered_cells_number, number)
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

  defp spawn_alive_cell(state, position) do
    {:ok, cell} = Cell.start_link position
    Map.update!(state, :cells, fn list ->
      list ++ [cell]
    end)
  end
end
