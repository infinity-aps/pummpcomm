defmodule Pummpcomm.History.ChangeBGReminderOffset do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
