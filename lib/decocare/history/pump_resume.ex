defmodule Decocare.History.PumpResume do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
