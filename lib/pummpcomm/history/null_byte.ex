defmodule Pummpcomm.History.NullByte do
  @moduledoc false

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{}
  def decode(<<>>, _), do: %{}
end
