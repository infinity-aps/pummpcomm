defmodule Decocare.History.BolusReminder do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
