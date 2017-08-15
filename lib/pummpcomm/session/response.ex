defmodule Pummpcomm.Session.Response do
  defstruct opcode: nil, data: <<>>, frames: [], last_frame?: nil

  alias Pummpcomm.Session.Packet
  alias Pummpcomm.Session.Response

  def add_packet(response = %Response{opcode: opcode}, packet = %Packet{opcode: opcode}) do
    <<last_frame::size(1), _frame_number::size(7), rest::binary>> = packet.payload
    {:ok, %{response | data: response.data <> rest, frames: [packet | response.frames], last_frame?: convert_last_frame(last_frame)}}
  end

  def add_packet(%Response{opcode: response_opcode}, %Packet{opcode: packet_opcode}) do
    {:error, "Packet's opcode #{packet_opcode} doesn't match expected response opcode #{response_opcode}"}
  end

  defp convert_last_frame(0), do: false
  defp convert_last_frame(_), do: true
end
