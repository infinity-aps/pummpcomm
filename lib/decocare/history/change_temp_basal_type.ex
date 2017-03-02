defmodule Decocare.History.ChangeTempBasalType do
  alias Decocare.DateDecoder

  def decode_change_temp_basal_type(<<basal_type::8, timestamp::binary-size(5)>>) do
    %{
      basal_type: basal_type(basal_type),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  defp basal_type(0x01), do: :percent
  defp basal_type(_), do: :absolute
end
