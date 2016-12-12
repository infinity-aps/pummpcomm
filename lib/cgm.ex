defmodule Cgm do
  use Bitwise

  @data_end                  0x01
  @sensor_weak_signal        0x02
  @sensor_calibration        0x03
  @sensor_packet             0x04
  @sensor_error              0x05
  @sensor_data_low           0x06
  @sensor_data_high          0x07
  @sensor_timestamp          0x08
  @battery_change            0x0A
  @sensor_status             0x0B
  @datetime_change           0x0C
  @sensor_sync               0x0D
  @cal_bg_for_gh             0x0E
  @sensor_calibration_factor 0x0F
  @ten_something             0x10
  @nineteen_something        0x13

  # Takes a page of cgm data and decodes events from it. Relative events
  # will not have timestamps, so the output from this needs to be run
  # though the timestamper
  def decode(page) do
    case Crc.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc.page_data |> reverse |> decode_page}
      other    -> other
    end
  end

  def decode_page(page_data), do: decode_page(page_data, [])
  def decode_page(<<>>, events), do: events

  def decode_page(<<0x00::size(8), tail::binary>>, events) do
    event = {:null_byte, %{raw: reverse(<<0x00>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@data_end, tail::binary>>, events) do
    event = {:data_end, %{raw: <<@data_end>>}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_weak_signal::size(8), tail::binary>>, events) do
    event = {:sensor_weak_signal, %{raw: reverse(<<@sensor_weak_signal>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_calibration::size(8), type::size(8), tail::binary>>, events) do
    event = {:sensor_calibration, %{calibration_type: calibration_type(type), raw: reverse(<<@sensor_calibration>> <> <<type>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_packet::size(8), type::size(8), tail::binary>>, events) do
    event = {:sensor_packet, %{packet_type: packet_type(type), raw: reverse(<<@sensor_packet>> <> <<type>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_error::size(8), type::size(8), tail::binary>>, events) do
    event = {:sensor_error, %{error_type: error_type(type), raw: reverse(<<@sensor_error>> <> <<type>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_data_high::size(8), unknown::size(8), tail::binary>>, events) do
    event = {:sensor_data_high, %{
                sgv: 400,
                raw: reverse(<<@sensor_data_high>> <> <<unknown>>)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_timestamp::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    <<_::size(16), type_code::unsigned-integer-size(8), _::binary>> = timestamp
    event = {:sensor_timestamp, %{
                event_type: timestamp_type(type_code &&& 0b01100000),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_timestamp>> <> timestamp)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@battery_change::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:battery_change, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@battery_change>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_status::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    <<_::size(16), type::unsigned-integer-size(8), _::binary>> = timestamp
    event = {:sensor_status, %{
                status_type: status_type(type &&& 0b01100000),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_status>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@datetime_change::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    event = {:datetime_change, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@datetime_change>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_sync::size(8), timestamp::binary-size(4), tail::binary>>, events) do
    <<_::size(16), type::unsigned-integer-size(8), _::binary>> = timestamp
    event = {:sensor_sync, %{
                sync_type: sync_type(type &&& 0b01100000),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_sync>> <> timestamp)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@cal_bg_for_gh::size(8), timestamp::binary-size(4), partial_amount::integer-unsigned-size(8), tail::binary>>, events) do
    <<_::size(16), origin::unsigned-integer-size(8), _::binary>> = timestamp
    event = {:cal_bg_for_gh, %{
                amount: partial_amount + (Enum.at(:binary.bin_to_list(timestamp), 3) &&& 0b00100000),
                origin_type: origin_type(origin &&& 0b01100000),
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

  def decode_page(<<@ten_something::size(8), timestamp::binary-size(4), more::size(24), tail::binary>>, events) do
    event = {:ten_something, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@ten_something>> <> timestamp <> <<more::size(24)>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@nineteen_something::size(8), tail::binary>>, events) do
    event = {:nineteen_something, %{raw: reverse(<<@nineteen_something>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_data_low::size(8), tail::binary>>, events) do
    event = {:sensor_data_low, %{sgv: 40, raw: <<@sensor_data_low>>}}
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

  defp calibration_type(0x00), do: :meter_bg_now
  defp calibration_type(0x01), do: :waiting
  defp calibration_type(0x02), do: :cal_error

  defp error_type(0x01), do: :end
  defp error_type(_), do: :unknown

  # defp packet_type(?), do: :pre_init
  defp packet_type(0x02), do: :init
  # defp packet_type(?), do: :burst
  defp packet_type(_), do: :unknown

  defp timestamp_type(0b00100000), do: :page_end
  defp timestamp_type(0b01000000), do: :gap
  defp timestamp_type(0b00000000), do: :last_rf
  defp timestamp_type(_         ), do: :unknown

  defp status_type(0b00000000), do: :off
  defp status_type(0b00100000), do: :on
  defp status_type(0b01000000), do: :lost

  defp sync_type(0b01100000), do: :find
  defp sync_type(0b00100000), do: :new
  defp sync_type(0b01000000), do: :old
  defp sync_type(_), do: :unknown

  defp origin_type(0b00000000), do: :rf
  defp origin_type(_), do: :unknown

  defp reverse(<<head::size(8), tail::binary>>), do: reverse(tail, <<head>>)
  defp reverse(<<>>, reversed), do: reversed
  defp reverse(<<head::size(8), tail::binary>>, reversed), do: reverse(tail, <<head>> <> reversed)
end
