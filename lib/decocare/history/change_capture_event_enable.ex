defmodule Decocare.History.ChangeCaptureEventEnable do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
