defmodule Pummpcomm.History.AlarmClockReminder do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
