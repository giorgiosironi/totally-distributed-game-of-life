defmodule GOL.Cell do
  alias GOL.Position
  alias GOL.ShardIndex

  def start_link(position, opts \\ []) do
    Agent.start_link(fn -> {position} end)
  end

  def position(cell) do
    Agent.get(cell, fn {position} -> position end)
  end

  def neighborhood_needed_number(cell) do
    9
  end

  def neighborhood_needed_number(cell, shard) do
    Agent.get(cell, fn {position} -> 
      Enum.count(neighborhoods_centers(position), fn center -> ShardIndex.contains(shard, center) end)
    end)
  end

  def neighborhoods(cell, target) do
    Agent.get(cell, fn {position} ->
      Enum.each(neighborhoods_centers(position), fn center ->
        target.(center, position)
      end)
    end)
  end

  def neighborhoods(cell, shard, target) do
    Agent.get(cell, fn {position} ->
      Enum.filter(neighborhoods_centers(position), fn center ->
        ShardIndex.contains(shard, center)
      end) |>
      Enum.each(fn center ->
        target.(center, position)
      end)
    end)
  end

  defp neighborhoods_centers(position) do
    for x <- [position.x - 1, position.x, position.x + 1],
        y <- [position.y - 1, position.y, position.y + 1] do
      Position.xy x, y
    end
  end
end
