defmodule Pummpcomm.History.SetAutoOff do
  @moduledoc """
  When the user enables/disabled auto-off.  Auto-off is a safety feature that stops insulin delivery after a defined
  time period (from 1 to 24 hours). If the pump detects that no buttons have been pressed for the selected amount of
  time in Auto-off, insulin delivery will stop and an alarm will sound. You may choose to program this feature into your
  pump based on the number of hours that you usually sleep at night.
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when auto-off was enabled/disabled
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode the time period
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
