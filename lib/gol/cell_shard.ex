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
        :cells => %{},
        :registered_cells_current => 0,
        :registered_cells_expected => nil,
        :alive_calls_queue => []
      },
      args
    )
  end

  def populate_alive_cell(shard, position) do
    GenServer.call(shard, {:populate_alive_cell, position})
  end

  def declare_empty(shard) do
    GenServer.call(shard, {:declare_empty})
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

  def alive(shard, position) do
    GenServer.call(shard, {:alive, position})
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
     spawn_alive_cell(state, position) |>
     count_all_cells_as_registered
    }
  end

  def handle_call({:declare_empty}, _from, state) do
    {:reply,
     nil,
     count_all_cells_as_registered state
    }
  end

  def handle_call({:alive}, from, state) do
    case registration_is_complete(state) do 
      true -> {:reply, all_alive_cells_positions(state), state}
      false -> {:noreply, enqueue_alive_call(state, {from, :alive})}
    end
  end

  def handle_call({:alive, position}, from, state) do
    case registration_is_complete(state) do 
      true -> {:reply, is_alive(state, position), state}
      false -> {:noreply, enqueue_alive_call(state, {from, :alive, position})}
    end
  end

  def handle_call({:evolve}, _from, state) do
    for_all_shards(state,
      fn shard_index ->
        emit_event(state, {
          :neighborhood_needed_number,
          shard_index,
          Enum.map(Map.values(state.cells), fn c ->
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
        Enum.each(Map.values(state.cells), fn source ->
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
    :ok = GenEvent.add_mon_handler(state.cell_events, handler, handler_state)
    {:reply, nil, state}
  end

  def handle_call({:register_evolved_cell, position, life}, _from, state) do
    if life == :alive do
      state = spawn_alive_cell(state, position)
    end
    state = Map.update!(state, :registered_cells_current, fn number -> number + 1 end)
    if registration_is_complete(state) do 
      state = empty_alive_calls_queue(state)
    end
    {:reply, nil, state}
  end

  def handle_call({:register_evolved_number, number}, _from, state) do
    state = Map.put(state, :registered_cells_expected, number)
    if registration_is_complete(state) do 
      state = empty_alive_calls_queue(state)
    end
    {:reply, nil, state}
  end

  defp for_all_shards(state, what_to_do) do
    Enum.each(
      ShardIndex.all(state.shard_index),
      what_to_do
    )
  end

  defp emit_event(state, event) do
    GenEvent.notify state.cell_events, event
  end

  defp spawn_alive_cell(state, position) do
    Map.update!(state, :cells, fn by_position ->
      if !Map.has_key? by_position, position do
        {:ok, cell} = Cell.start_link position
        by_position = Map.put by_position, position, cell
      end
      by_position
    end)
  end

  defp registration_is_complete(state) do
    state[:registered_cells_current] == state[:registered_cells_expected]
  end

  defp enqueue_alive_call(state, call) do
    Map.update!(state, :alive_calls_queue, fn queue -> [call|queue] end) 
  end

  defp empty_alive_calls_queue(state) do
    Enum.each(state[:alive_calls_queue], fn 
      {from, :alive} -> GenServer.reply from, all_alive_cells_positions(state)
      {from, :alive, position} -> GenServer.reply from, is_alive(state, position)
    end)
    Map.put(state, :alive_calls_queue, [])
  end

  defp count_all_cells_as_registered(state) do
    total = Enum.count state.cells
    state |>
    Map.put(:registered_cells_current, total) |>
    Map.put(:registered_cells_expected, total)
  end

  defp all_alive_cells_positions(state) do
    # TODO: parallelize in some way,
    # just use Map.keys(state.cells) ?
    for c <- Map.values(state.cells) do
      Cell.position c
    end
  end

  defp is_alive(state, position) do
    Map.has_key? state.cells, position
  end
end
