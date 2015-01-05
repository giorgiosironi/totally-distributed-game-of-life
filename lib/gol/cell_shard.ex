defmodule GOL.CellShard do
  use GenServer

  def start_link(generation, shard_index, args \\ []) do
    GenServer.start_link(
      __MODULE__, 
      %{
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

  def init(state) do
    {:ok, state}
  end

  def handle_call({:add_alive_cell, position}, _from, state) do
    # TODO: create Cell Agent
    {:reply, nil, Map.update!(state, :cells, fn list -> list ++ [position] end)}
  end

  def handle_call({:alive}, _from, state) do
    {:reply, state.cells, state}
  end
end
