defmodule Decocare.History.BolusWizardSetup do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
