defmodule Decocare.History.NullByte do
  def decode(<<>>, _), do: %{}
end
