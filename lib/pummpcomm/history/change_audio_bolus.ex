defmodule Pummpcomm.History.ChangeAudioBolus do
  # TODO figure out what this means and document module and callback
  @moduledoc false

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  # TODO decode change
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
