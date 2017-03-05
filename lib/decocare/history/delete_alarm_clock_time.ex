defmodule Decocare.History.DeleteAlarmClockTime do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
