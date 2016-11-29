defmodule DateDecoder do
  use Bitwise

  def decode_timestamp(timestamp_data) do
    ts_bytes = :binary.bin_to_list(timestamp_data)

    {:ok, timestamp} = NaiveDateTime.new(year(ts_bytes), month(ts_bytes), day(ts_bytes), hour(ts_bytes), minute(ts_bytes), 0)
    timestamp
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
