defmodule Pummpcomm.History.ClearSettings do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
