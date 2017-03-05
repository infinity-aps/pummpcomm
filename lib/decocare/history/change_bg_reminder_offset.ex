defmodule Decocare.History.ChangeBGReminderOffset do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
