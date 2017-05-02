defmodule Pummpcomm.History.ChangeAlarmClockEnable do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
