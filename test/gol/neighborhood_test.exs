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

  test "when has 3 alive neighbors will be alive" do
    own_center = Position.xy(1, 6)
    {:ok, neighborhood} = Neighborhood.start_link own_center
    Neighborhood.one_cell_is_alive neighborhood, own_center
    Neighborhood.one_cell_is_alive neighborhood, nil
    Neighborhood.one_cell_is_alive neighborhood, nil
    Neighborhood.one_cell_is_alive neighborhood, nil
    parent = self()
    Neighborhood.to_new_cell neighborhood, fn center, life -> send parent, {center, life} end
    assert_receive {_, :alive}
  end

  test "when has 2 alive neighbors and is alive will remain alive" do
    own_center = Position.xy(1, 6)
    {:ok, neighborhood} = Neighborhood.start_link own_center
    Neighborhood.one_cell_is_alive neighborhood, own_center
    Neighborhood.one_cell_is_alive neighborhood, nil
    Neighborhood.one_cell_is_alive neighborhood, nil
    parent = self()
    Neighborhood.to_new_cell neighborhood, fn center, life -> send parent, {center, life} end
    assert_receive {_, :alive}
  end

  test "when has 2 alive neighbors and is dead will remain dead" do
    own_center = Position.xy(1, 6)
    {:ok, neighborhood} = Neighborhood.start_link own_center
    Neighborhood.one_cell_is_alive neighborhood, nil
    Neighborhood.one_cell_is_alive neighborhood, nil
    parent = self()
    Neighborhood.to_new_cell neighborhood, fn center, life -> send parent, {center, life} end
    assert_receive {_, :dead}
  end

  test "when has more than 3 alive neighbors will die of overcrowding" do
    own_center = Position.xy(1, 6)
    {:ok, neighborhood} = Neighborhood.start_link own_center
    Neighborhood.one_cell_is_alive neighborhood, own_center
    Neighborhood.one_cell_is_alive neighborhood, nil
    Neighborhood.one_cell_is_alive neighborhood, nil
    Neighborhood.one_cell_is_alive neighborhood, nil
    Neighborhood.one_cell_is_alive neighborhood, nil
    parent = self()
    Neighborhood.to_new_cell neighborhood, fn center, life -> send parent, {center, life} end
    assert_receive {_, :dead}
  end
end

