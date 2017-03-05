defmodule Decocare.History.DailyTotal523 do
  def event_type, do: :daily_total_523
  defdelegate decode(body, pump_options), to: Decocare.History.DailyTotal
end
