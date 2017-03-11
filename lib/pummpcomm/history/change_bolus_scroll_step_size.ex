defmodule Pummpcomm.History.ChangeBolusScrollStepSize do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
