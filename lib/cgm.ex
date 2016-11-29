defmodule Cgm do
  @data_end           0x01
  @sensor_timestamp   0x08
  @nineteen_something 0x13

  def decode(page) do
    case Crc.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc.page_data |> reverse |> decode_page}
      other    -> other
    end
  end

  def decode_page(page_data), do: decode_page(page_data, [])
  def decode_page(<<>>, events), do: Timestamper.timestamp_relative_events(events)

  def decode_page(<<@sensor_timestamp::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_timestamp, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@data_end::size(8), tail::binary>>, events) do
    decode_page(tail, [{:data_end} | events])
  end

  def decode_page(<<@nineteen_something::size(8), tail::binary>>, events) do
    decode_page(tail, [{:nineteen_something} | events])
  end

  def decode_page(<<sgv::unsigned-integer-size(8), tail::binary>>, events) when sgv >= 20 do
    sgv = sgv * 2
    decode_page(tail, [{:sensor_glucose_value, %{sgv: sgv}} | events])
  end

  defp reverse(<<head::size(8), tail::binary>>), do: reverse(tail, <<head>>)
  defp reverse(<<>>, reversed), do: reversed
  defp reverse(<<head::size(8), tail::binary>>, reversed), do: reverse(tail, <<head>> <> reversed)
end
