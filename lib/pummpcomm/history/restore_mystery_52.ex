defmodule Pummpcomm.History.RestoreMystery52 do
  def event_type, do: :restore_mystery_52
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
