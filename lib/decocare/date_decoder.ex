defmodule Decocare.DateDecoder do
  use Bitwise

  #  +=====================================================================+
  #  | BYTE    0  |        |        1  |        |   2   |       | 3        |
  #  | MONTH HIGH |   HOUR | MONTH LOW | MINUTE | FLAGS |   DAY |     YEAR |
  #  + -----------+--------+-----------+--------+-------+-------+----------+
  #  |         xx | 0xxxxx |        xx | xxxxxx |   xxx | xxxxx | 0xxxxxxx |
  #  +=====================================================================+

  def decode_timestamp(timestamp = <<month_high::2, _::1, hour::5, month_low::2, minute::6, _flags::3, day::5, _::1, year::7>>) when is_binary(timestamp) do
    <<month::4>> = <<month_high::2, month_low::2>>
    case NaiveDateTime.new(2000 + year, month, day, hour, minute, 0) do
      {:ok, timestamp} -> timestamp
    end
  end

  def decode_timestamp(timestamp) do
    decode_timestamp(<<timestamp::32>>)
  end
end
