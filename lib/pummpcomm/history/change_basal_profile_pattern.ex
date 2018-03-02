defmodule Pummpcomm.History.ChangeBasalProfilePattern do
  @moduledoc """
  When the basal profile pattern was changed
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestmap` when the basal profile pattern was changed.
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode infomation about new profile pattern
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
