defmodule Pummpcomm.History.ChangeMaxBolus do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
