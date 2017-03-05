defmodule Decocare.History.SetAutoOff do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
