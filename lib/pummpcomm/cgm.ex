defmodule Pummpcomm.Cgm do
  use Bitwise
  alias Pummpcomm.DateDecoder, as: DateDecoder
  alias Pummpcomm.Crc16,       as: Crc16
  alias Pummpcomm.Timestamper, as: Timestamper

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
    case Crc16.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc16.page_data |> reverse |> decode_page |> Timestamper.timestamp_events}
      other    -> other
    end
  end

  def decode_page(page_data), do: decode_page(page_data, [])
  def decode_page(<<>>, events), do: events

  def decode_page(<<0x00::8, tail::binary>>, events) do
    event = {:null_byte, %{raw: <<0x00>>}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@data_end, tail::binary>>, events) do
    event = {:data_end, %{raw: <<@data_end>>}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_weak_signal::8, tail::binary>>, events) do
    event = {:sensor_weak_signal, %{raw: <<@sensor_weak_signal>>}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_calibration::8, type::8, tail::binary>>, events) do
    event = {:sensor_calibration, %{calibration_type: calibration_type(type), raw: reverse(<<@sensor_calibration::8, type::8>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_packet::8, type::8, tail::binary>>, events) do
    event = {:sensor_packet, %{packet_type: packet_type(type), raw: reverse(<<@sensor_packet::8, type::8>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_error::8, type::8, tail::binary>>, events) do
    event = {:sensor_error, %{error_type: error_type(type), raw: reverse(<<@sensor_error::8, type::8>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_data_high::8, unknown::8, tail::binary>>, events) do
    event = {:sensor_data_high, %{
                sgv: 400,
                raw: reverse(<<@sensor_data_high::8, unknown::8>>)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_timestamp::8, timestamp::32, tail::binary>>, events) do
    event = {:sensor_timestamp, %{
                event_type: timestamp_type(flags(timestamp) &&& 0b011),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_timestamp::8, timestamp::32>>)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@battery_change::8, timestamp::32, tail::binary>>, events) do
    event = {:battery_change, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@battery_change::8, timestamp::32>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_status::8, timestamp::32, tail::binary>>, events) do
    event = {:sensor_status, %{
                status_type: status_type(flags(timestamp) &&& 0b011),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_status::8, timestamp::32>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@datetime_change::8, timestamp::32, tail::binary>>, events) do
    event = {:datetime_change, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@datetime_change::8, timestamp::32>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_sync::8, timestamp::32, tail::binary>>, events) do
    event = {:sensor_sync, %{
                sync_type: sync_type(flags(timestamp) &&& 0b011),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_sync::8, timestamp::32>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@cal_bg_for_gh::8, timestamp::32, partial_amount::8, tail::binary>>, events) do
    event = {:cal_bg_for_gh, %{
                amount: partial_amount,
                origin_type: origin_type(flags(timestamp) &&& 0b011),
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@cal_bg_for_gh::8, timestamp::32, partial_amount::8>>)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_calibration_factor::8, timestamp::32, raw_factor::16, tail::binary>>, events) do
    event = {:sensor_calibration_factor, %{
                factor: raw_factor / 1000.0,
                timestamp: DateDecoder.decode_timestamp(timestamp),
                raw: reverse(<<@sensor_calibration_factor::8, timestamp::32, raw_factor::16>>)
             }}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@ten_something::8, timestamp::32, more::24, tail::binary>>, events) do
    event = {:ten_something, %{timestamp: DateDecoder.decode_timestamp(timestamp), raw: reverse(<<@ten_something::8, timestamp::32, more::24>>)}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@nineteen_something::8, tail::binary>>, events) do
    event = {:nineteen_something, %{raw: <<@nineteen_something>>}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<@sensor_data_low::8, tail::binary>>, events) do
    event = {:sensor_data_low, %{sgv: 40, raw: <<@sensor_data_low>>}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<raw_sgv::8, tail::binary>>, events) when raw_sgv >= 20 do
    event = {:sensor_glucose_value, %{sgv: raw_sgv * 2, raw: <<raw_sgv>>}}
    decode_page(tail, [event | events])
  end

  def decode_page(<<unknown::8, tail::binary>>, events) do
    event = {:unknown, %{raw: <<unknown>>}}
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

  defp timestamp_type(0b001), do: :page_end
  defp timestamp_type(0b010), do: :gap
  defp timestamp_type(0b000), do: :last_rf
  defp timestamp_type(_         ), do: :unknown

  defp status_type(0b000), do: :off
  defp status_type(0b001), do: :on
  defp status_type(0b010), do: :lost

  defp sync_type(0b011), do: :find
  defp sync_type(0b001), do: :new
  defp sync_type(0b010), do: :old
  defp sync_type(_    ), do: :unknown

  defp origin_type(0b000), do: :rf
  defp origin_type(_    ), do: :unknown

  defp flags(timestamp = <<_::16, flags::3, _::bitstring>>) when is_binary(timestamp), do: flags
  defp flags(timestamp), do: flags(<<timestamp::32>>)

  defp reverse(<<head::8, tail::binary>>), do: reverse(tail, <<head>>)
  defp reverse(<<>>, reversed), do: reversed
  defp reverse(<<head::8, tail::binary>>, reversed), do: reverse(tail, <<head>> <> reversed)
end
