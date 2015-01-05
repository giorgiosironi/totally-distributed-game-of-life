defmodule GOL.ShardIndexTest do
  use ExUnit.Case
  alias GOL.ShardIndex

  test "can calculate whether a number belongs to its shard" do
    index = %ShardIndex{current: 2, total: 4}
    assert ShardIndex.contains(index, 2)
    assert ShardIndex.contains(index, 6)
    assert false = ShardIndex.contains(index, 7)
    assert false = ShardIndex.contains(index, 8)
    assert false = ShardIndex.contains(index, 9)
  end
end
