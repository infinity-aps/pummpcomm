defmodule Pummpcomm.History.DeleteOtherDeviceID do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
