defmodule Pummpcomm.History.ChangeBGReminderEnable do
  @moduledoc """
  When the BG Reminder was enabled/disabled.
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  @doc """
  `timestamp` when the BG Reminder was enabled/disabled.
  """
  # TODO decode whether it's enabled or disabled
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
