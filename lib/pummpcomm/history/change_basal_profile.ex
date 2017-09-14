defmodule Pummpcomm.History.ChangeBasalProfile do
  @moduledoc """
  When the basal profile is changed
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestmap` when the basal profile was changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode infomation about new profile
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
