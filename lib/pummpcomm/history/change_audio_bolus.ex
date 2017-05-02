defmodule Pummpcomm.History.ChangeAudioBolus do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
