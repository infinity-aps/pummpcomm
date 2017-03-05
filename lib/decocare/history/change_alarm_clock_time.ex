defmodule Decocare.History.ChangeAlarmClockTime do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
