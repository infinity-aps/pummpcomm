defmodule Decocare.History.DeleteOtherDeviceID do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
