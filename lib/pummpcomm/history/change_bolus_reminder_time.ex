defmodule Pummpcomm.History.ChangeBolusReminderTime do
  @moduledoc """
  When the bolus reminder time was changed
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when bolus reminder time was changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode bolus reminder time
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
