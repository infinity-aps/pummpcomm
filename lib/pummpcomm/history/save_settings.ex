defmodule Pummpcomm.History.SaveSettings do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
