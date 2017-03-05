defmodule Decocare.History.ChangeCarbUnits do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
