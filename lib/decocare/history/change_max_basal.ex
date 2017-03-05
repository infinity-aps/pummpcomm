defmodule Decocare.History.ChangeMaxBasal do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
