defmodule Pummpcomm.History.ChangeReservoirWarningTime do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
