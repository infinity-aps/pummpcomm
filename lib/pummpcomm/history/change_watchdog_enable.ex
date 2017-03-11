defmodule Pummpcomm.History.ChangeWatchdogEnable do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
