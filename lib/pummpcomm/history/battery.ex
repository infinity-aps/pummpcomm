defmodule Pummpcomm.History.Battery do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
