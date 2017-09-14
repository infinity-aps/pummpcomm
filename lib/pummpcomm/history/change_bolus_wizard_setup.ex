defmodule Pummpcomm.History.ChangeBolusWizardSetup do
  @moduledoc """
  When Bolus Wizard setting where changed
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when Bolus Wizard setting where changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new bolus wizard settings
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
