defmodule Pummpcomm.History.SelectBasalProfile do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
