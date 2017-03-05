defmodule Decocare.History.ChangeVariableBolus do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
