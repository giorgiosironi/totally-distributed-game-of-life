defmodule GOL.ShardIndex do
  defstruct current: 0, total: 4

  def from(representation) do
    [current_string, total_string] = String.split(representation, "in")
    {current, ""} = Integer.parse current_string
    {total, ""} = Integer.parse total_string
    %GOL.ShardIndex{current: current, total: total}
  end

  def contains(index, number) do
    rem(number, index.total) == index.current
  end
end
