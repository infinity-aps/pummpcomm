defmodule Pummpcomm.History.ChangeBGReminderOffset do
  @moduledoc """
  When the offset after a bolus when the BG Reminder is shown changed.
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  @doc """
  `timestamp` when the offset after a bolus when the BG Reminder is shown changed.
  """
  # TODO decode new offset
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
