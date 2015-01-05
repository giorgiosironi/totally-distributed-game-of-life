defmodule GOL.ShardIndex do
  defstruct current: 0, total: 4

  def contains(index, number) do
    rem(number, index.total) == index.current
  end
end
