defmodule Pummpcomm.History.DeleteBolusReminderTime do
  @moduledoc """
  `Bolus` > `Bolus Setup` > `Missed Bolus Reminder` > `Delete Reminder`
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timstamp` when user did `Bolus` > `Bolus Setup` > `Missed Bolus Reminder` > `Delete Reminder`
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode which reminder was deleted
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
