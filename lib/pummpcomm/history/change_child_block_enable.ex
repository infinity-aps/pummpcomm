defmodule Pummpcomm.History.ChangeChildBlockEnable do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
