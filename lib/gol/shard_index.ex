defmodule GOL.ShardIndex do
  defstruct current: 0, total: 4

  def from(representation) do
    [current_string, total_string] = String.split(representation, "in")
    {current, ""} = Integer.parse current_string
    {total, ""} = Integer.parse total_string
    true = current < total
    true = current >= 0
    %GOL.ShardIndex{current: current, total: total}
  end

  def contains(index, number) do
    rem(number, index.total) == index.current
  end

  def all(index) do
    for i <- 0..index.total-1 do
      %GOL.ShardIndex{current: i, total: index.total}
    end
  end
end
