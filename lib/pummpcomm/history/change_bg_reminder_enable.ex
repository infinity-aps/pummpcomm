defmodule Pummpcomm.History.ChangeBGReminderEnable do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
