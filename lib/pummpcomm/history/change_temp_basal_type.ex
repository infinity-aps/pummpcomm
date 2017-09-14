defmodule Pummpcomm.History.ChangeTempBasalType do
  @moduledoc """
  When the temporary `basal_type` is changed between `:absolute` and `:percentage`
  """

  alias Pummpcomm.{DateDecoder, TempBasal}

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the temporary `basal_type` is changed between `:absolute` and `:percentage`
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{basal_type: TempBasal.type, timestamp: NaiveDateTime.t}
  def decode(body, pump_options)
  def decode(<<basal_type::8, timestamp::binary-size(5)>>, _) do
    %{
      basal_type: basal_type(basal_type),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  ## Private Functions

  defp basal_type(0x01), do: :percent
  defp basal_type(_), do: :absolute
end
