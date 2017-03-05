defmodule Decocare.History.ClearAlarm do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
