defmodule GOL.ShardedNeighborhoodEventHandler do
  use GenEvent

  def handle_event(event, state) do
    IO.inspect(event)
    {:ok, state}
  end
end
