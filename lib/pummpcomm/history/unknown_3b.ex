defmodule Pummpcomm.History.Unknown3B do
  def event_type, do: :unknown_3b
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
