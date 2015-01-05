defmodule GOL.Neighborhood do
  use GenServer
  
  def start_link(position, opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      %{
        :position => position,
        :center => nil,
        :alive_neighbors => 0
      },
      opts
    )
  end

  def one_cell_is_alive(neighborhood, position) do
    GenServer.call(neighborhood, {:one_cell_is_alive, position})
  end

  def to_new_cell(neighborhood, target) do
    GenServer.call(neighborhood, {:to_new_cell, target})
  end

  def handle_call({:one_cell_is_alive, p}, _from, state) do
    {:reply, nil, Map.update!(state, :alive_neighbors, fn number ->
      number + 1
    end)}
  end

  def handle_call({:to_new_cell, target}, _from, state) do
    if state.alive_neighbors >= 4 do
      target.(state.position, :alive)
    else
      target.(state.position, :dead)
    end
    {:reply, nil, state}
  end
end
