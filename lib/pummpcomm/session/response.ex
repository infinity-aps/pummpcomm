defmodule Pummpcomm.Session.Response do
  defstruct opcode: nil, data: <<>>, frames: []

  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Packet

  def add_packet(response = %Response{opcode: opcode}, packet = %Packet{opcode: opcode}) do
    <<_frame_number::8, rest::binary>> = packet.payload
    %{response | data: response.data <> rest, frames: [packet | response.frames]}
  end

  def get_data(%Response{opcode: 0x8D, data: <<length::8, rest::binary>>}) do
    %{model_number: binary_part(rest, 0, length)}
  end
end
