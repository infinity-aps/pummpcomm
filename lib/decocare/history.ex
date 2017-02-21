defmodule Decocare.History do
  alias Decocare.Crc16, as: Crc16
  alias Decocare.DateDecoder, as: DateDecoder

  @cal_bg_for_ph 0x0A
  @alarm_sensor  0x0B

  def decode(page) do
    case Crc16.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc16.page_data |> decode_page |> Enum.reverse}
      other    -> other
    end
  end

  def decode_page(page_data), do: decode_page(page_data, [])
  def decode_page(<<>>, events), do: events

  def decode_page(<<@cal_bg_for_ph, amount::8, timestamp::40, tail::binary>>, events) do
    event = {:cal_bg_for_ph, %{amount: amount, timestamp: DateDecoder.decode_history_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@alarm_sensor::8, alarm_type::8, alarm_param::8, timestamp::40, tail::binary>>, events) do
    event = {:alarm_sensor, %{timestamp: DateDecoder.decode_history_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end
end
