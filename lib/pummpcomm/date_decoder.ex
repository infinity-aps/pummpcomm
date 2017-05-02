defmodule Pummpcomm.DateDecoder do
  use Bitwise

  #  +========================================================================+
  #  | BYTE    0  |        |        1  |        |   2   |       | 3           |
  #  | MONTH HIGH |   HOUR | MONTH LOW | MINUTE | FLAGS |   DAY | 2000 + YEAR |
  #  + -----------+--------+-----------+--------+-------+-------+-------------+
  #  |         xx | 0xxxxx |        xx | xxxxxx |   xxx | xxxxx |    0xxxxxxx |
  #  +========================================================================+

  def decode_timestamp(timestamp = <<month_high::2, _::1, hour::5, month_low::2, minute::6, _flags::3, day::5, _::1, year::7>>) when is_binary(timestamp) do
    <<month::4>> = <<month_high::2, month_low::2>>
    case NaiveDateTime.new(2000 + year, month, day, hour, minute, 0) do
      {:ok, timestamp} -> timestamp
    end
  end

  def decode_timestamp(timestamp) do
    decode_timestamp(<<timestamp::32>>)
  end


  #  +===================================================================================================+
  #  | BYTE    0  |        |        1  |        |   2   |       |       | 3        | 4     |             |
  #  | MONTH HIGH | SECOND | MONTH LOW | MINUTE | FLAGS |  HOUR | FLAGS |      DAY | FLAGS | 2000 + YEAR |
  #  + -----------+--------+-----------+--------+-------+-------+-------+----------+-------+-------------+
  #  |         xx | xxxxxx |        xx | xxxxxx |   xxx | xxxxx |   xxx |    xxxxx |     x |     xxxxxxx |
  #  +===================================================================================================+

  def decode_history_timestamp(timestamp = <<month_high::2, second::6, month_low::2, minute::6, _::3, hour::5, _::3, day::5, _::1, year::7>>) when is_binary(timestamp) do
    <<month::4>> = <<month_high::2, month_low::2>>
    case NaiveDateTime.new(2000 + year, month, day, hour, minute, second) do
      {:ok, timestamp} -> timestamp
    end
  end

  #  +===========================================+
  #  | BYTE    0  |        |        1  |         |
  #  | MONTH HIGH |    DAY | MONTH LOW |    YEAR |
  #  + -----------+--------+-----------+---------+
  #  |        xxx |  xxxxx |         x | xxxxxxx |
  #  +===========================================+

  def decode_history_timestamp(timestamp = <<month_high::3, day::5, month_low::1, year::7>>) when is_binary(timestamp) do
    <<month::4>> = <<month_high::3, month_low::1>>
    case NaiveDateTime.new(2000 + year, month, day, 0, 0, 0) do
      {:ok, timestamp} -> timestamp
    end
  end
end
