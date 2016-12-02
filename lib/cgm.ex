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
    event = {:null_byte, %{raw: reverse(<<0x00>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@data_end::size(8), tail::binary>>, events) do
    event = {:data_end, %{raw: reverse(<<@data_end>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_weak_signal::size(8), tail::binary>>, events) do
    event = {:sensor_weak_signal, %{raw: reverse(<<@sensor_weak_signal>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_calibration::size(8), 0x01::size(8), tail::binary>>, events) do
    event = {:sensor_calibration, %{waiting: :waiting, raw: reverse(<<@sensor_calibration>> <> <<0x01>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_calibration::size(8), meter_bg_now::size(8), tail::binary>>, events) do
    event = {:sensor_calibration, %{waiting: :meter_bg_now, raw: reverse(<<@sensor_calibration>> <> <<meter_bg_now>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@fokko7::size(8), unknown::size(8), tail::binary>>, events) do
    event = {:fokko7, %{raw: reverse(<<@fokko7>> <> <<unknown>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_timestamp::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_timestamp, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@sensor_timestamp>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@battery_change::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:battery_change, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@battery_change>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_status::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_status, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@sensor_status>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@datetime_change::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:datetime_change, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@datetime_change>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_sync::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:sensor_sync, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@sensor_sync>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@cal_bg_for_gh::size(8), timestamp::binary-size(4), partial_amount::integer-unsigned-size(8), tail::binary>>, events) do
    event = {:cal_bg_for_gh, %{
                amount: partial_amount + (Enum.at(:binary.bin_to_list(timestamp), 3) &&& 0b00100000),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@cal_bg_for_gh>> <> timestamp <> <<partial_amount::integer-unsigned-size(8)>>)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_calibration_factor::size(8), timestamp::binary-size(4), raw_factor::integer-unsigned-size(16), tail::binary>>, events) do
    event = {:sensor_calibration_factor, %{
                factor: raw_factor / 1000.0,
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_calibration_factor>> <> timestamp <> <<raw_factor::integer-unsigned-size(16)>>)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@ten_something::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:ten_something, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@ten_something>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@nineteen_something::size(8), tail::binary>>, events) do
    event = {:nineteen_something, %{raw: reverse(<<@nineteen_something>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<raw_sgv::unsigned-integer-size(8), tail::binary>>, events) when raw_sgv >= 20 do
    event = {:sensor_glucose_value, %{sgv: raw_sgv * 2, raw: reverse(<<raw_sgv>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<unknown::size(8), tail::binary>>, events) do
    event = {:unknown, %{raw: reverse(<<unknown>>)}}
    decode_page(tail, [event | events])
  end

  defp reverse(<<head::size(8), tail::binary>>), do: reverse(tail, <<head>>)
  defp reverse(<<>>, reversed), do: reversed
  defp reverse(<<head::size(8), tail::binary>>, reversed), do: reverse(tail, <<head>> <> reversed)
end
