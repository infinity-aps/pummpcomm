defmodule Pummpcomm.History.ChangeMeterID do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
