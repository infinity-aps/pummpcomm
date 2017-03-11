defmodule Pummpcomm.History.ChangeTimeDisplay do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
