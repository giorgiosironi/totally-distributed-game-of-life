defmodule GOL.CellShardTest do
  use ExUnit.Case
  alias GOL.CellShard
  alias GOL.Position
  alias GOL.ShardIndex

  defmodule Forwarder do
    use GenEvent

    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end

  setup do
    {:ok, manager} = GenEvent.start_link
    GenEvent.add_mon_handler(manager, Forwarder, self())

    {:ok, manager: manager}
  end

  test "knows a set of cells and their positions", %{manager: manager} do
    {:ok, shard} = CellShard.start_link manager, 1, ShardIndex.from "0in4"
    CellShard.add_alive_cell shard, Position.xy(5, 6)
    assert [Position.xy(5, 6)] == CellShard.alive shard
  end

  test "tells all cells to evolve", %{manager: manager} do
    {:ok, shard} = CellShard.start_link manager, 1, ShardIndex.from "0in4"
    CellShard.add_alive_cell shard, Position.xy(5, 6)
    #CellShard.evolve shard
  end
end
