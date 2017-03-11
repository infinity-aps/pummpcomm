defmodule Pummpcomm.History.ChangeWatchdogMarriageProfile do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
