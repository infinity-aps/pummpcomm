defmodule Decocare.History.ChangeSensorAlarmSilenceConfig do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
