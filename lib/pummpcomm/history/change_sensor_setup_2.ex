defmodule Pummpcomm.History.ChangeSensorSetup2 do
  def event_type, do: :change_sensor_setup_2
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
