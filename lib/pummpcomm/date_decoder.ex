defmodule Pummpcomm.DateDecoder do
  use Bitwise

  @doc """
  This function decodes a full date and time as returned by the ReadTime command
  """
  def decode_full_datetime(<<hour::8, minute::8, second::8, year::size(16), month::8, day::8>>) do
    case NaiveDateTime.new(year, month, day, hour, minute, second) do
      {:ok, timestamp} -> timestamp
    end
  end

  @doc """
  decodes a cgm timestamp binary whose format is described in the following table:

  +========================================================================+
  | BYTE    0  |        |        1  |        |   2   |       | 3           |
  | MONTH HIGH |   HOUR | MONTH LOW | MINUTE | FLAGS |   DAY | 2000 + YEAR |
  + -----------+--------+-----------+--------+-------+-------+-------------+
  |         xx | 0xxxxx |        xx | xxxxxx |   xxx | xxxxx |    0xxxxxxx |
  +========================================================================+
  """
  def decode_cgm_timestamp(timestamp = <<month_high::2, _::1, hour::5, month_low::2, minute::6, _flags::3, day::5, _::1, year::7>>) when is_binary(timestamp) do
    <<month::4>> = <<month_high::2, month_low::2>>
    case NaiveDateTime.new(2000 + year, month, day, hour, minute, 0) do
      {:ok, timestamp} -> timestamp
    end
  end

  def decode_cgm_timestamp(timestamp) do
    decode_cgm_timestamp(<<timestamp::32>>)
  end

  @doc """
  decodes a history page long timestamp whose format is described in the following table:

  +===================================================================================================+
  | BYTE    0  |        |        1  |        |   2   |       |       | 3        | 4     |             |
  | MONTH HIGH | SECOND | MONTH LOW | MINUTE | FLAGS |  HOUR | FLAGS |      DAY | FLAGS | 2000 + YEAR |
  + -----------+--------+-----------+--------+-------+-------+-------+----------+-------+-------------+
  |         xx | xxxxxx |        xx | xxxxxx |   xxx | xxxxx |   xxx |    xxxxx |     x |     xxxxxxx |
  +===================================================================================================+
  """
  def decode_history_timestamp(timestamp = <<month_high::2, second::6, month_low::2, minute::6, _::3, hour::5, _::3, day::5, _::1, year::7>>) when is_binary(timestamp) do
    <<month::4>> = <<month_high::2, month_low::2>>
    case NaiveDateTime.new(2000 + year, month, day, hour, minute, second) do
      {:ok, timestamp} -> timestamp
    end
  end

  @doc """
  decodes a history page short timestamp (date only) whose format is described in the following table:

  +===========================================+
  | BYTE    0  |        |        1  |         |
  | MONTH HIGH |    DAY | MONTH LOW |    YEAR |
  + -----------+--------+-----------+---------+
  |        xxx |  xxxxx |         x | xxxxxxx |
  +===========================================+
  """
  def decode_history_timestamp(timestamp = <<month_high::3, day::5, month_low::1, year::7>>) when is_binary(timestamp) do
    <<month::4>> = <<month_high::3, month_low::1>>
    case NaiveDateTime.new(2000 + year, month, day, 0, 0, 0) do
      {:ok, timestamp} -> timestamp
    end
  end
end
