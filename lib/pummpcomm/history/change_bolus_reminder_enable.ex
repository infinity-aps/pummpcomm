defmodule Pummpcomm.History.ChangeBolusReminderEnable do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
