defmodule Pummpcomm.History.ChangeBasalProfilePattern do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
