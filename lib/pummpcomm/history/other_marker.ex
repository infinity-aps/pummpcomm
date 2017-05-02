defmodule Pummpcomm.History.OtherMarker do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
