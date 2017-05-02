defmodule Pummpcomm.History.ChangeSensorAlarmSilenceConfig do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
