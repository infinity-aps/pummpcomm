defmodule Pummpcomm.History.ChangeMaxBasal do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
