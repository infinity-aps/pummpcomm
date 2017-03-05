defmodule Decocare.History.ChangeBolusReminderTime do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
