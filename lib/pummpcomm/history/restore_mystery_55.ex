defmodule Pummpcomm.History.RestoreMystery55 do
  def event_type, do: :restore_mystery_55
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
