defmodule Pummpcomm.History.PumpSuspend do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
