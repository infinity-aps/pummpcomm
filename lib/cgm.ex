defmodule Cgm do
  use Bitwise

  def decode(page) do
    case Crc.check_crc_16(page) do
      {:ok, _} -> {:ok, Crc.page_data(page) |> reverse |> decode_page}
      other    -> other
    end
  end

  def decode_page(page_data), do: decode_page(page_data, [])
  def decode_page(<<>>, events), do: events

  @sensor_timestamp 0x08
  def decode_page(<<@sensor_timestamp::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    decode_page(tail, [{:sensor_timestamp, timestamp: decode_timestamp(timestamp)} | events])
  end

  @nineteen_something 0x13
  def decode_page(<<@nineteen_something::size(8), tail::binary>>, events) do
    decode_page(tail, [{:nineteen_something} | events])
  end

  defp reverse(<<head::size(8), tail::binary>>), do: reverse(tail, <<head>>)
  defp reverse(<<>>, reversed), do: reversed
  defp reverse(<<head::size(8), tail::binary>>, reversed), do: reverse(tail, <<head>> <> reversed)

  def decode_timestamp(timestamp_data) do
    ts_bytes = :binary.bin_to_list(timestamp_data)

    %{
      year:   year(ts_bytes),
      month:  month(ts_bytes),
      day:    day(ts_bytes),
      hour:   hour(ts_bytes),
      minute: minute(ts_bytes)
    }
  end

  defp year(ts_bytes),   do: 2000 + (Enum.at(ts_bytes, 3) &&& 0b01111111)
  defp month(ts_bytes) do
    ((Enum.at(ts_bytes, 0) &&& 0b11000000) >>> 4) +
    ((Enum.at(ts_bytes, 1) &&& 0b11000000) >>> 6)
  end
  defp day(ts_bytes),    do: Enum.at(ts_bytes, 2) &&& 0b00011111
  defp hour(ts_bytes),   do: Enum.at(ts_bytes, 0) &&& 0b00011111
  defp minute(ts_bytes), do: Enum.at(ts_bytes, 1) &&& 0b00111111
end
