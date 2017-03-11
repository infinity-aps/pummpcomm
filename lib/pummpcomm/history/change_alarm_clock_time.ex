defmodule Pummpcomm.History.ChangeAlarmClockTime do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
