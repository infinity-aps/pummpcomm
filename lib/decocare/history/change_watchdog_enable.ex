defmodule Decocare.History.ChangeWatchdogEnable do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
