defmodule Pummpcomm.History.BolusReminder do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
