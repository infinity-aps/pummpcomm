defmodule Pummpcomm.History.RestoreMystery54 do
  @moduledoc false

  @behaviour Pummpcomm.History.Decoder

  # Functions

  def event_type, do: :restore_mystery_54

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
