defmodule Decocare.History.ChangeAudioBolus do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
