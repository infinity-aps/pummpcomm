defmodule Decocare.History.ChangeBolusReminderEnable do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
