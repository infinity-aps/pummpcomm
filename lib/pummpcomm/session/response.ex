defmodule Pummpcomm.Session.Response do
  @moduledoc """
  Response to a `Pummpcomm.Session.Command`.
  """

  alias Pummpcomm.Session.{Packet, Response}

  # Constants

  @ack 0x06

  # Struct

  defstruct opcode: nil, data: <<>>, frames: [], last_frame?: nil

  # Types

  @typedoc """
  * `opcode` - response opcode
  * `data` - data across all frames.  data is in-order.
  * `frames` - accumulated frames, for a multi-frame response.  Frames are in reverse-order.
  * `last_frame?` - if all `frames` have been received and `data` is complete
  """
  @type t :: %Response{
               opcode: byte,
               data: binary,
               frames: [Packet.t],
               last_frame?: boolean | nil
             }

  # Functions

  @doc """
  Adds `packet` to `response`.
  """
  @spec add_packet(Response.t, Packet.t) :: {:ok, Response.t} | {:error, String.t}

  def add_packet(response = %Response{opcode: opcode}, packet = %Packet{opcode: opcode}) do
    <<last_frame::size(1), _frame_number::size(7), rest::binary>> = packet.payload
    {:ok, %{response | data: response.data <> rest, frames: [packet | response.frames], last_frame?: convert_last_frame(last_frame)}}
  end

  def add_packet(%Response{}, packet = %Packet{opcode: @ack}) do
    {:ok, %Response{opcode: @ack, data: packet.payload, frames: [packet], last_frame?: true}}
  end

  def add_packet(%Response{opcode: response_opcode}, %Packet{opcode: packet_opcode}) do
    {:error, "Packet's opcode #{packet_opcode} doesn't match expected response opcode #{response_opcode}"}
  end

  ## Private Functions

  defp convert_last_frame(0), do: false
  defp convert_last_frame(_), do: true
end
