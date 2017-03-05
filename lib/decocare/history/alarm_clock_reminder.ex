defmodule Decocare.History.AlarmClockReminder do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
