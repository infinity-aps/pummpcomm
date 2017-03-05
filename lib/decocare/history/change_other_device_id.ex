defmodule Decocare.History.ChangeOtherDeviceID do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
