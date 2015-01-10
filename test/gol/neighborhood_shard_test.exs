defmodule GOL.NeighborhoodShardTest do
  use ExUnit.Case
  alias GOL.NeighborhoodShard
  alias GOL.Position
  alias GOL.ShardIndex
  alias GOL.Forwarder

  test "after the number of relevant neighborhood needed is known it can tell them to evolve" do
    {:ok, manager} = GenEvent.start_link
    own_shard = ShardIndex.from "0in4"
    {:ok, shard} = NeighborhoodShard.start_link manager, 2, own_shard
    NeighborhoodShard.attach_event_handler shard, Forwarder, self()

    NeighborhoodShard.number_will_be shard, 2
    NeighborhoodShard.number_will_be shard, 0
    NeighborhoodShard.number_will_be shard, 0
    NeighborhoodShard.number_will_be shard, 1
    NeighborhoodShard.needed_in shard, Position.xy(0, 1), Position.xy(0, 0)
    NeighborhoodShard.needed_in shard, Position.xy(0, 1), Position.xy(0, 1)
    NeighborhoodShard.needed_in shard, Position.xy(0, 1), Position.xy(0, 2)

    assert_receive {:cells_considered, ^own_shard, 1}
    populated_center = Position.xy 0, 1
    assert_receive {:cell, ^own_shard, ^populated_center, :alive}

  end
end
