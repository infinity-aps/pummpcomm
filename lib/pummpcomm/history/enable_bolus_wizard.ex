defmodule Pummpcomm.History.EnableBolusWizard do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
