defmodule GOL.Display do
  alias GOL.Facade
  alias GOL.Position

  @doc """
  Displays the part of generation that falls into the rectangle that has `lower_corner` and `upper_corner` has vertices.
  `lower_corner` is on the top left of the screen and `upper_corner` is on the bottom right, so that the X axis is horizontal from left to right, and the Y axis is vertical from up to down.
  """
  def window lower_corner, upper_corner, generation do
    lines = for y <- lower_corner.y..upper_corner.y do
      chars_of_line = for x <- lower_corner.x..upper_corner.x do
        case Facade.alive generation, Position.xy(x, y) do
          true -> "X"
          false -> " "
        end
      end
      (Enum.join chars_of_line, "") <> "\n"
    end
    Enum.join lines, ""
  end
end
