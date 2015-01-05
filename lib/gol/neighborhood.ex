defmodule GOL.Neighborhood do
  use GenServer
  
  def start_link(position, opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      %{
        :position => position,
        :center => :dead,
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

  def handle_call({:one_cell_is_alive, position}, _from, state) do
    IO.inspect(position)
    if position == state.position do
      {:reply, nil, Map.update!(state, :center, fn c -> :alive end)}
    else
      {:reply, nil, Map.update!(state, :alive_neighbors, fn number ->
        number + 1
      end)}
    end
  end

  def handle_call({:to_new_cell, target}, _from, state) do
    case {state.center, state.alive_neighbors} do
      {:alive, 3} -> next = :alive
      {:dead, 3} -> next = :alive
      {:alive, 2} -> next = :alive
      _ -> next = :dead
    end
    target.(state.position, next)
    {:reply, nil, state}
  end
end
