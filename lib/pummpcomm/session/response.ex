defmodule Pummpcomm.Session.Response do
  require Logger
  defstruct opcode: nil, data: <<>>, frames: []

  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Packet

  def add_packet(response = %Response{opcode: opcode}, packet = %Packet{opcode: opcode}) do
    <<last_frame::size(1), frame_number::size(7), rest::binary>> = packet.payload
    Logger.info "Received packet with frame #{frame_number}. Last frame?: #{last_frame}"
    {:ok, %{response | data: response.data <> rest, frames: [packet | response.frames]}}
  end

  def add_packet(%Response{opcode: response_opcode}, %Packet{opcode: packet_opcode}) do
    {:error, "Packet's opcode #{packet_opcode} doesn't match expected response opcode #{response_opcode}"}
  end

  def get_data(%Response{opcode: 0x8D, data: <<length::8, rest::binary>>}) do
    %{model_number: binary_part(rest, 0, length)}
  end
end
