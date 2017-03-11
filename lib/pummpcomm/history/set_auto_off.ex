defmodule Pummpcomm.History.SetAutoOff do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
