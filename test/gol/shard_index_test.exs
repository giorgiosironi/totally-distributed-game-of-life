defmodule GOL.ShardIndexTest do
  use ExUnit.Case
  alias GOL.ShardIndex
  alias GOL.Position

  test "can calculate whether a number belongs to its shard" do
    index = ShardIndex.from "2in4"
    assert ShardIndex.contains(index, Position.xy(2, 42))
    assert ShardIndex.contains(index, Position.xy(6, 42))
    assert false = ShardIndex.contains(index, Position.xy(7, 42))
    assert false = ShardIndex.contains(index, Position.xy(8, 42))
    assert false = ShardIndex.contains(index, Position.xy(9, 42))
  end

  test "index goes from 0 to the total number of shards, excluded" do
    assert catch_error(ShardIndex.from "4in4") == {:badmatch, false}
  end

  test "can be dumped as string" do
    assert "3in4" = String.Chars.to_string(ShardIndex.from "3in4")
  end

  test "can generate a list of all shards" do
    index = ShardIndex.from "2in4"
    all = [
      ShardIndex.from("0in4"),
      ShardIndex.from("1in4"),
      ShardIndex.from("2in4"),
      ShardIndex.from("3in4")
    ] 
    assert all == ShardIndex.all index
  end
end
