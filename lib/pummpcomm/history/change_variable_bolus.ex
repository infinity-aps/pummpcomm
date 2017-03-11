defmodule Pummpcomm.History.ChangeVariableBolus do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
