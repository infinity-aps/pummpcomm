defmodule Decocare.History.ChangeAlarmNotifyMode do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
