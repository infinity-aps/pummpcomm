defmodule Pummpcomm.History.ChangeTempBasalType do
  alias Pummpcomm.DateDecoder

  def decode(<<basal_type::8, timestamp::binary-size(5)>>, _) do
    %{
      basal_type: basal_type(basal_type),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  defp basal_type(0x01), do: :percent
  defp basal_type(_), do: :absolute
end
