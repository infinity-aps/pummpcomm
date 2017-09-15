defmodule Pummpcomm.History.ChangeCaptureEventEnable do
  @moduledoc """
  When `Utilities` > `Capture Options` is toggled `On` or `Off`
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when `Utilities` > `Capture Options` is toggled `On` or `Off`
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode whether enabled or disabled
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
