defmodule Pummpcomm.History.BolusWizardSetup do
  @moduledoc """
  When Bolus Wizard was setup
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when Bolus Wizard was setup
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode bolus wizard settings
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
