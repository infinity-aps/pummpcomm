defmodule Decocare.History.DailyTotal522 do
  def event_type, do: :daily_total_522
  defdelegate decode(body, pump_options), to: Decocare.History.DailyTotal
end
