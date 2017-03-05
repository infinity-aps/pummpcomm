defmodule Decocare.History.SelectBasalProfile do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
