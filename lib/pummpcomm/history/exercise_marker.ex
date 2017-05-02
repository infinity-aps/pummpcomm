defmodule Pummpcomm.History.ExerciseMarker do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
