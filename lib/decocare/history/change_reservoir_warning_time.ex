defmodule Decocare.History.ChangeReservoirWarningTime do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
