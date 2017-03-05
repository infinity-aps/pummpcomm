defmodule Decocare.History.ChangeMaxBolus do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
