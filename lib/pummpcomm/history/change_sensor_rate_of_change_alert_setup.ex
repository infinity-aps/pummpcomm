defmodule Pummpcomm.History.ChangeSensorRateOfChangeAlertSetup do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
