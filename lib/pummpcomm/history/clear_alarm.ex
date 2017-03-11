defmodule Pummpcomm.History.ClearAlarm do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
