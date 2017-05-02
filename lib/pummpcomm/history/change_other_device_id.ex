defmodule Pummpcomm.History.ChangeOtherDeviceID do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
