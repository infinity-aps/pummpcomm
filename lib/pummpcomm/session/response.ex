defmodule Pummpcomm.Session.Response do
  require Logger
  defstruct opcode: nil, data: <<>>, frames: [], last_frame?: nil

  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Packet

  def add_packet(response = %Response{opcode: opcode}, packet = %Packet{opcode: opcode}) do
    <<last_frame::size(1), _frame_number::size(7), rest::binary>> = packet.payload
    # Logger.info "Received packet with frame #{frame_number}. Last frame?: #{last_frame}"
    {:ok, %{response | data: response.data <> rest, frames: [packet | response.frames], last_frame?: convert_last_frame(last_frame)}}
  end

  def add_packet(%Response{opcode: response_opcode}, %Packet{opcode: packet_opcode}) do
    {:error, "Packet's opcode #{packet_opcode} doesn't match expected response opcode #{response_opcode}"}
  end

  def get_data(%Response{opcode: 0x8D, data: <<length::8, rest::binary>>}) do
    {:ok, model_number} = Pummpcomm.PumpModel.model_number(binary_part(rest, 0, length))
    %{model_number: model_number}
  end

  def get_data(%Response{opcode: 0xCD, data: <<page_number::size(32), glucose::size(16), isig::size(16), _rest::binary>>}) do
    %{page_number: page_number, glucose: glucose, isig: isig}
  end

  def get_data(%Response{opcode: 0x9A, data: data}) do
    Pummpcomm.Cgm.decode(data)
  end

  def get_data(%Response{opcode: 0x70, data: <<encoded_date::binary-size(7), _::binary>>}) do
    Pummpcomm.DateDecoder.decode_full_datetime(encoded_date)
  end

  def get_data(%Response{opcode: 0x80, data: data}, pump_model) do
    Pummpcomm.History.decode(data, pump_model)
  end

  defp convert_last_frame(0), do: false
  defp convert_last_frame(_), do: true
end
