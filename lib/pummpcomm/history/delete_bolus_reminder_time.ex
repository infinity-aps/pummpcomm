defmodule Pummpcomm.History.DeleteBolusReminderTime do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
