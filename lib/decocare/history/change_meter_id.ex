defmodule Decocare.History.ChangeMeterID do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
