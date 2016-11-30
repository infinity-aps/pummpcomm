defmodule Cgm do
  use Bitwise

  @data_end                  0x01
  @sensor_weak_signal        0x02
  @sensor_calibration        0x03
  @fokko7                    0x07
  @sensor_timestamp          0x08
  @battery_change            0x0A
  @sensor_status             0x0B
  @datetime_change           0x0C
  @sensor_sync               0x0D
  @cal_bg_for_gh             0x0E
  @sensor_calibration_factor 0x0F
  @ten_something             0x10
  @nineteen_something        0x13

  def decode(page) do
    case Crc.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc.page_data |> reverse |> decode_page}
      other    -> other
    end
  end

  def decode_page(page_data), do: decode_page(page_data, [])
  def decode_page(<<>>, events), do: Timestamper.timestamp_relative_events(events)

  def decode_page(<<0x00::size(8), tail::binary>>, events) do
    decode_page(tail, events)
  end

  def decode_page(<<@data_end::size(8), tail::binary>>, events) do
    decode_page(tail, [{:data_end} | events])
  end

  def decode_page(<<@sensor_weak_signal::size(8), tail::binary>>, events) do
    decode_page(tail, [{:sensor_weak_signal} | events])
  end

  def decode_page(<<@sensor_calibration::size(8), waiting::size(8), tail::binary>>, events) do
    waiting = case waiting do
                0x01 -> :waiting
                _    -> :meter_bg_now
              end
    decode_page(tail, [{:sensor_calibration, %{waiting: waiting}} | events])
  end

  def decode_page(<<@fokko7::size(8), _unknown::size(8), tail::binary>>, events) do
    decode_page(tail, [{:fokko7, %{}} | events])
  end

  def decode_page(<<@sensor_timestamp::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_timestamp, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@battery_change::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:battery_change, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_status::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_status, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@datetime_change::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:datetime_change, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_sync::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_sync, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@cal_bg_for_gh::size(8), timestamp::binary-size(4), partial_amount::integer-unsigned-size(8), tail::binary>>, events) do
    amount = partial_amount + (Enum.at(:binary.bin_to_list(timestamp), 3) &&& 0b00100000)
    event = {:cal_bg_for_gh, %{amount: amount, timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_calibration_factor::size(8), timestamp::binary-size(4), factor::integer-unsigned-size(16), tail::binary>>, events) do
    factor = factor / 1000.0
    event = {:sensor_calibration_factor, %{factor: factor, timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@ten_something::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:ten_something, %{timestamp: DateDecoder.decode_timestamp(timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@nineteen_something::size(8), tail::binary>>, events) do
    decode_page(tail, [{:nineteen_something} | events])
  end

  def decode_page(<<sgv::unsigned-integer-size(8), tail::binary>>, events) when sgv >= 20 do
    sgv = sgv * 2
    decode_page(tail, [{:sensor_glucose_value, %{sgv: sgv}} | events])
  end

  def decode_page(<<_unknown::size(8), tail::binary>>, events) do
    decode_page(tail, [{:unknown, %{}} | events])
  end

  defp reverse(<<head::size(8), tail::binary>>), do: reverse(tail, <<head>>)
  defp reverse(<<>>, reversed), do: reversed
  defp reverse(<<head::size(8), tail::binary>>, reversed), do: reverse(tail, <<head>> <> reversed)
end
