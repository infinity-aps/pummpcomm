defmodule Pummpcomm.History.EnableDisableRemote do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
