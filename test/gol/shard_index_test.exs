defmodule GOL.ShardIndexTest do
  use ExUnit.Case
  alias GOL.ShardIndex

  test "can calculate whether a number belongs to its shard" do
    index = ShardIndex.from "2in4"
    assert ShardIndex.contains(index, 2)
    assert ShardIndex.contains(index, 6)
    assert false = ShardIndex.contains(index, 7)
    assert false = ShardIndex.contains(index, 8)
    assert false = ShardIndex.contains(index, 9)
  end

  test "index goes from 0 to the total number of shards, excluded" do
    assert catch_error(ShardIndex.from "4in4") == {:badmatch, false}
  end

  test "can generate a list of all shards" do
    index = ShardIndex.from "2in4"
    all = [
      ShardIndex.from("0in4"),
      ShardIndex.from("1in4"),
      ShardIndex.from("2in4"),
      ShardIndex.from("3in4")
    ] 
    assert all = ShardIndex.all index
  end
end
