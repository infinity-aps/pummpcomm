defmodule Pummpcomm.History.BolusWizardSetup do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
