defmodule Pummpcomm.History.ChangeAlarmClockEnable do
  @moduledoc """
  When the alarm clock is enabled/disabled
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  The `timestamp` when the alarm clock is enabled/disabled.
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode enable/disable
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
