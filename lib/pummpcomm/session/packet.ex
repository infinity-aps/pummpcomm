defmodule Pummpcomm.Session.Packet do
  @moduledoc """
  A general packet for sending `Pummpcomm.Session.Command.t` and receive `Pummp.Session.Response.t`
  """

  alias Pummpcomm.Crc.Crc8
  alias Pummpcomm.Session.{Command, Packet}

  # Constants

  @types %{
    carelink: 0xA7
  }

  # Struct

  @enforce_keys [:pump_serial, :opcode, :payload, :type]
  defstruct pump_serial: nil, opcode: nil, payload: nil, date: nil, type: nil

  # Types

  @typedoc """
  * `pump_serial` - serial number of the pump
  """
  @type t :: %Packet{
               # TODO determine where `date` is used
               date: term,
               opcode: non_neg_integer,
               payload: binary,
               pump_serial: String.t,
               type: non_neg_integer
             }

  @doc """
  Parses `Pummpcomm.Session.Packet.t` out of `bytes`

  ## Returns

  * `{:invalid_packet, "Packet too short"}` - fewer than 6 bytes are given
  * `{:ok, Pummpcomm.Session.Response.t}` - packet could be parsed and CRC8 check passed
  * `{:invalid_packet, "CRC doesn't match"}` - packet could be parsed, but CRC8 check failed

  """
  @spec from_binary(<<>>) :: {:invalid_packet, String.t} | {:ok, t}
  def from_binary(bytes) when byte_size(bytes) <= 5, do: {:invalid_packet, "Packet too short"}
  def from_binary(<<rf_type::8, serial::binary-size(3), opcode::8, payload_and_crc::binary>>) do
    payload_size = byte_size(payload_and_crc) - 1
    <<payload::binary-size(payload_size), crc::8>> = payload_and_crc
    packet = %Packet{
      pump_serial: decode_serial(serial),
      opcode: opcode,
      payload: payload,
      type: rf_type
    }
    case crc == Crc8.crc_8(crc_components(packet)) do
      true  -> {:ok, packet}
               false -> {:invalid_packet, "CRC doesn't match"}
    end
  end

  @doc """
  Converts `command` to `t`
  """
  @spec from_command(Command.t) :: {:ok, t}
  def from_command(command), do: from_command(command, Command.payload(command))

  @doc """
  Converts `command` to `t`, using given `payload` instead of getting `payload` from `command` `params`.
  """
  @spec from_command(Command.t, binary) :: {:ok, t}
  def from_command(command, payload) do
    {:ok,
     %Packet{
       pump_serial: command.pump_serial,
       opcode: command.opcode,
       payload: payload,
       type: @types[:carelink]
     }
    }
  end

  @doc """
  Converts `packet` to binary format used to transmit to pump
  """
  @spec to_binary(t) :: binary
  def to_binary(packet) do
    components = crc_components(packet)
    components <> <<Crc8.crc_8(components)::8>>
  end

  ## Private Functions

  defp crc_components(packet) do
    <<packet.type::8>> <> encode_serial(packet.pump_serial) <> <<packet.opcode::8>> <> packet.payload
  end

  defp decode_serial(bytes) do
    Base.encode16(bytes)
  end

  defp encode_serial(serial) do
    encoded = serial |> Integer.parse(16) |> elem(0)
    <<encoded::size(24)>>
  end
end
