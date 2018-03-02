defmodule Pummpcomm.History.ChangeAlarmClockTime do
  @moduledoc """
  When the alarm clock time was changed
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the alarm clock time was changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new alarm clock time
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
