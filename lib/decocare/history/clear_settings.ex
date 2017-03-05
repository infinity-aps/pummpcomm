defmodule Decocare.History.ClearSettings do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
