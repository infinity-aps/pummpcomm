defmodule Decocare.History.SaveSettings do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
