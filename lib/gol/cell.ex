defmodule GOL.Cell do
  def start_link(position, opts \\ []) do
    Agent.start_link(fn -> {position} end)
  end

  def position(cell) do
    Agent.get(cell, fn {position} -> position end)
  end
end
