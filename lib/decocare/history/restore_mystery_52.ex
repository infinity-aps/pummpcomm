defmodule Decocare.History.RestoreMystery52 do
  def event_type, do: :restore_mystery_52
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
