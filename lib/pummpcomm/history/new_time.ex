defmodule Pummpcomm.History.NewTime do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
