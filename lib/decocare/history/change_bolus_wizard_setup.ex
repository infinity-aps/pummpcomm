defmodule Decocare.History.ChangeBolusWizardSetup do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
