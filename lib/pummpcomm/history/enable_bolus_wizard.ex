defmodule Pummpcomm.History.EnableBolusWizard do
  @moduledoc """
  `Bolus` > `Bolus Setup` > `Bolus Wizard Setup` > `Edit Settings` > `Wizard`
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` user toggled `Bolus` > `Bolus Setup` > `Bolus Wizard Setup` > `Edit Settings` > `Wizard`
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode whether it's enable/disable
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
