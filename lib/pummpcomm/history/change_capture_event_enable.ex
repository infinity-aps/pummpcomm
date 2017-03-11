defmodule Pummpcomm.History.ChangeCaptureEventEnable do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
