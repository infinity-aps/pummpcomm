defmodule Pummpcomm.History.ChangeBolusReminderTime do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
