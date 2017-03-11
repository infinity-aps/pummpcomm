defmodule Pummpcomm.History.PumpResume do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
