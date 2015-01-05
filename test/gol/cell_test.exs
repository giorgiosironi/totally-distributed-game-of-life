defmodule GOL.CellTest do
  use ExUnit.Case
  alias GOL.Cell
  alias GOL.Position

  test "stores its position" do
    {:ok, cell} = Cell.start_link Position.xy(4, 5)
    assert Position.xy(4, 5) == Cell.position cell
  end
end
