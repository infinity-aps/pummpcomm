defmodule Pummpcomm.History.LowBattery do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
