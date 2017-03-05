defmodule Decocare.History.ChangeSensorRateOfChangeAlertSetup do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
