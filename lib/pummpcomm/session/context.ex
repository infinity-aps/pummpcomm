defmodule Pummpcomm.Session.Context do
  defstruct command: nil, response: nil, received_ack: false, error: nil, sent_params: false
  alias Pummpcomm.Session.Context
  alias Pummpcomm.Session.Response

  def received_ack(context = %Context{}) do
    %{context | received_ack: true}
  end

  def sent_params(context = %Context{}) do
    %{context | sent_params: true}
  end

  def add_response(context = %Context{response: nil}, response_packet) do
    add_response(%{context | response: %Response{opcode: context.command.opcode}}, response_packet)
  end

  def add_response(context = %Context{response: response}, response_packet) do
    case Response.add_packet(response, response_packet) do
      {:ok, response}  -> %{context | response: response}
      {:error, reason} -> %{context | error: reason}
    end
  end

  def add_error(context = %Context{}, error) do
    %{context | error: error}
  end
end
