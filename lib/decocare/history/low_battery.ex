defmodule Decocare.History.LowBattery do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
