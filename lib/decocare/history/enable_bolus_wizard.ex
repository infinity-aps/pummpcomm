defmodule Decocare.History.EnableBolusWizard do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
