defmodule GOL.NeighborhoodTest do
  use ExUnit.Case
  alias GOL.Neighborhood
  alias GOL.Position

  test "when created has 0 alive neighbors and so would be dead" do
    own_center = Position.xy(1, 6)
    {:ok, neighborhood} = Neighborhood.start_link own_center
    Neighborhood.one_cell_is_alive neighborhood, own_center
    parent = self()
    Neighborhood.to_new_cell neighborhood, fn center, life -> send parent, {center, life} end
    assert_receive {own_center, :dead}
  end
end

