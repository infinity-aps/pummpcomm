defmodule Pummpcomm.History.NullByte do
  def decode(<<>>, _), do: %{}
end
