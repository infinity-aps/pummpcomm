defmodule Decocare.History.ChangeChildBlockEnable do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
