defmodule GOL.Neighborhood do
  use GenServer
  
  def start_link(position, opts \\ []) do
    GenServer.start_link(__MODULE__, {position}, opts)
  end

  def one_cell_is_alive(neighborhood, position) do
    GenServer.call(neighborhood, {:one_cell_is_alive, position})
  end

  def to_new_cell(neighborhood, target) do
    GenServer.call(neighborhood, {:to_new_cell, target})
  end

  def handle_call({:one_cell_is_alive, p}, _from, {position}) do
    {:reply, nil, {position}}
  end

  def handle_call({:to_new_cell, target}, _from, {position}) do
    target.(position, :dead)
    {:reply, nil, {position}}
  end
end
