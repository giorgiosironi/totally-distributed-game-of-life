defmodule GOL.Position do
  defstruct x: nil, y: nil

  def xy(x, y) do
    %GOL.Position{x: x, y: y}
  end
end
