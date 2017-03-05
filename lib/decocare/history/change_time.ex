defmodule Decocare.History.ChangeTime do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
