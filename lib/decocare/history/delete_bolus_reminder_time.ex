defmodule Decocare.History.DeleteBolusReminderTime do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
