defmodule Decocare.History.ChangeBGReminderEnable do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
