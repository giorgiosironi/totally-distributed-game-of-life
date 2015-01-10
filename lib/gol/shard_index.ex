defmodule GOL.ShardIndex do
  alias GOL.Position
  # to be able to use ShardIndex in pattern matching
  alias __MODULE__
  defstruct current: nil, total: nil

  def from(representation) do
    [current_string, total_string] = String.split(representation, "in")
    {current, ""} = Integer.parse current_string
    {total, ""} = Integer.parse total_string
    true = current < total
    true = current >= 0
    %GOL.ShardIndex{current: current, total: total}
  end

  def contains(index, %Position{x: x}) do
    rem(x, index.total) == index.current
  end

  def all(%ShardIndex{total: total}) do
    all(total)
  end

  def all(total) do
    for i <- 0..total-1 do
      %GOL.ShardIndex{current: i, total: total}
    end
  end
end

defimpl String.Chars, for: GOL.ShardIndex do
  def to_string(index) do
    "#{index.current}in#{index.total}"
  end
end
