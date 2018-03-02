defmodule Pummpcomm.History.ChangeBolusReminderEnable do
  @moduledoc """
  When the Bolus Reminder was enabled/disabled.
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  @doc """
  `timestmap` when the Bolus Reminder was enabled/disabled.
  """
  # TODO decode whether enabled or disabled
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
