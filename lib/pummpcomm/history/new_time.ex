defmodule Pummpcomm.History.NewTime do
  @moduledoc false

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
