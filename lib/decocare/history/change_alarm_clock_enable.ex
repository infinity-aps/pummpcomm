defmodule Decocare.History.ChangeAlarmClockEnable do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
