defmodule Pummpcomm.History.RestoreMystery54 do
  def event_type, do: :restore_mystery_54
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
