defmodule Pummpcomm.History.ChangeCarbUnits do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
