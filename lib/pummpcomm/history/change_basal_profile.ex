defmodule Pummpcomm.History.ChangeBasalProfile do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
