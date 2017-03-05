defmodule Decocare.History.OtherMarker do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
