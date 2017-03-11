defmodule Pummpcomm.History.ChangeAlarmNotifyMode do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
