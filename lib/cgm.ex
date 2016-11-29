defmodule Cgm do
  def decode(page) do
    case Crc.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc.page_data |> reverse |> decode_page}
      other    -> other
    end
  end

  def decode_page(page_data), do: decode_page(page_data, [])
  def decode_page(<<>>, events), do: Timestamper.timestamp_relative_events(events)

  @sensor_timestamp 0x08
  def decode_page(<<@sensor_timestamp::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_timestamp, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  @nineteen_something 0x13
  def decode_page(<<@nineteen_something::size(8), tail::binary>>, events) do
    decode_page(tail, [{:nineteen_something} | events])
  end

  defp reverse(<<head::size(8), tail::binary>>), do: reverse(tail, <<head>>)
  defp reverse(<<>>, reversed), do: reversed
  defp reverse(<<head::size(8), tail::binary>>, reversed), do: reverse(tail, <<head>> <> reversed)
end
