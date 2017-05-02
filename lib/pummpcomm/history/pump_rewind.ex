defmodule Pummpcomm.History.PumpRewind do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
