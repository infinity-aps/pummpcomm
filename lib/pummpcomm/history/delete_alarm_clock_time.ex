defmodule Pummpcomm.History.DeleteAlarmClockTime do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
