defmodule GOL.CellShardTest do
  use ExUnit.Case
  alias GOL.CellShard
  alias GOL.Position
  alias GOL.ShardIndex
  alias GOL.Forwarder

  setup do
    {:ok, manager} = GenEvent.start_link
    :ok = GenEvent.add_mon_handler(manager, Forwarder, self())
    # TODO: extract here creation of own_shard_index and shard

    {:ok, manager: manager}
  end

  test "knows a set of cells and their positions", %{manager: manager} do
    {:ok, shard} = CellShard.start_link manager, 1, ShardIndex.from "0in4"
    CellShard.populate_alive_cell shard, Position.xy(0, 6)
    assert [Position.xy(0, 6)] == CellShard.alive shard
  end

  test "can test the lifeness of a cell", %{manager: manager} do
    {:ok, shard} = CellShard.start_link manager, 1, ShardIndex.from "0in4"
    CellShard.populate_alive_cell shard, Position.xy(0, 6)
    assert true == CellShard.alive shard, Position.xy(0, 6)
    assert false == CellShard.alive shard, Position.xy(1, 6)
  end

  test "adding alive cells is idempotent", %{manager: manager} do
    {:ok, shard} = CellShard.start_link manager, 1, ShardIndex.from "0in4"
    CellShard.populate_alive_cell shard, Position.xy(0, 6)
    CellShard.populate_alive_cell shard, Position.xy(0, 6)
    assert 1 == Enum.count CellShard.alive shard
  end

  test "tells all cells to evolve", %{manager: manager} do
    own_shard_index = ShardIndex.from "0in4"
    {:ok, shard} = CellShard.start_link manager, 1, own_shard_index
    CellShard.populate_alive_cell shard, Position.xy(0, 6)
    CellShard.evolve shard
    assert_receive {:neighborhood_needed_number, ^own_shard_index, 3}

    near_shard_index = ShardIndex.from "1in4"
    assert_receive {:neighborhood_needed_number, ^near_shard_index, 3}


    existing_cell_position = Position.xy(0, 6)
    assert_receive {:neighborhood_needed, ^own_shard_index, ^existing_cell_position, ^existing_cell_position}
    side_cell_position = Position.xy(0, 7)
    assert_receive {:neighborhood_needed, ^own_shard_index, ^side_cell_position, ^existing_cell_position}
    near_shard_cell_position = Position.xy(1, 6)
    assert_receive {:neighborhood_needed, ^near_shard_index, ^near_shard_cell_position, ^existing_cell_position}
  end

  test "some cell shards may be empty", %{manager: manager} do
    own_shard_index = ShardIndex.from "0in4"
    {:ok, shard} = CellShard.start_link manager, 1, own_shard_index
    CellShard.evolve shard
    assert_receive {:neighborhood_needed_number, ^own_shard_index, 0}
  end

  test "registers an evolution", %{manager: manager} do
    own_shard_index = ShardIndex.from "0in4"
    {:ok, shard} = CellShard.start_link manager, 1, own_shard_index
    CellShard.register_evolved_cell shard, Position.xy(0, 2), :alive
    CellShard.register_evolved_cell shard, Position.xy(4, 5), :dead
    CellShard.register_evolved_number shard, 2

    assert [Position.xy(0, 2)] == CellShard.alive shard
  end

  test "a partial evolution blocks the alive calls until complete registration", %{manager: manager} do
    own_shard_index = ShardIndex.from "0in4"
    {:ok, shard} = CellShard.start_link manager, 1, own_shard_index
    CellShard.register_evolved_cell shard, Position.xy(0, 0), :alive

    spawn_link(fn -> assert [Position.xy(0, 0), Position.xy(0, 1)] == CellShard.alive shard end)
    spawn_link(fn -> assert CellShard.alive shard, Position.xy(0, 1) end)
    # let the spawned assertion execute
    :timer.sleep 1
    
    CellShard.register_evolved_cell shard, Position.xy(0, 1), :alive
    CellShard.register_evolved_number shard, 2
  end

  test "when declared empty can be consulted with alive calls", %{manager: manager} do
    own_shard_index = ShardIndex.from "0in4"
    {:ok, shard} = CellShard.start_link manager, 1, own_shard_index
    CellShard.declare_empty shard

    assert [] == CellShard.alive shard
  end
end

