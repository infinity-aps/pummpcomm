defmodule Pummpcomm.Packet do
  alias Pummpcomm.Command
  alias Pummpcomm.Crc.Crc8

  @enforce_keys [:pump_serial, :opcode, :payload, :date, :type]
  defstruct pump_serial: nil, opcode: nil, payload: nil, date: nil, type: nil

  @types %{
    carelink: 0xA7
  }
  def from_command(command), do: from_command(command, Command.payload(command))
  def from_command(command, payload) do
    {:ok,
     %Pummpcomm.Packet{
       pump_serial: command.pump_serial,
       opcode: command.opcode,
       payload: payload,
       date: DateTime.to_naive(Timex.local),
       type: @types[:carelink]
     }
    }
  end

  def from_binary(bytes) when byte_size(bytes) <= 5, do: {:invalid_packet, "Packet too short"}
  def from_binary(<<rf_type::8, serial::binary-size(3), opcode::8, payload_and_crc::binary>>) do
    payload_size = byte_size(payload_and_crc) - 1
    <<payload::binary-size(payload_size), crc::8>> = payload_and_crc
    packet = %Pummpcomm.Packet{
      pump_serial: decode_serial(serial),
      opcode: opcode,
      payload: payload,
      date: DateTime.to_naive(Timex.local),
      type: rf_type
    }
    IO.inspect packet
    case crc == Crc8.crc_8(crc_components(packet)) do
      true  -> {:ok, packet}
               false -> {:invalid_packet, "CRC doesn't match"}
    end
  end

  def to_binary(packet) do
    components = crc_components(packet)
    components <> <<Crc8.crc_8(components)::8>>
  end

  def crc_components(packet) do
    <<packet.type::8>> <> encode_serial(packet.pump_serial) <> <<packet.opcode::8>> <> packet.payload
  end

  defp encode_serial(serial) do
    encoded = serial |> Integer.parse(16) |> elem(0)
    <<encoded::size(24)>>
  end

  defp decode_serial(bytes) do
    Base.encode16(bytes)
  end
end
