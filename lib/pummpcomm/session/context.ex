defmodule Pummpcomm.Session.Context do
  @moduledoc """
  The context around executing a `Pummpcomm.Session.Command.t`
  """

  alias Pummpcomm.Session.{Context, Response}

  # Struct

  defstruct command: nil, response: nil, received_ack: false, error: nil, sent_params: false

  # Types

  @typedoc """
  """
  @type t :: %Context{
          command: Pummpcomm.Session.Command.t(),
          response: Pummpcomm.Session.Response.t() | nil,
          received_ack: boolean,
          # TODO determine if there's something more specific than term for error shape
          error: term,
          sent_params: boolean
        }

  # Functions

  @doc """
  Adds `error` to `context`
  """
  @spec add_error(t, term) :: t
  def add_error(context = %Context{}, error) do
    %{context | error: error}
  end

  @doc """
  Adds `response_packet` to `context`'s `response`.

  If `context` doesn't have a `response` yet, one will be added.

  If there is an error adding `response_packet` to the existing `response`, then `t` `error` will be set with that
  error.
  """

  @spec add_response(%Context{response: nil}, Pummpcomm.Session.Packet.t()) :: %Context{
          response: Response.t()
        }
  def add_response(context = %Context{response: nil}, response_packet) do
    add_response(
      %{context | response: %Response{opcode: context.command.opcode}},
      response_packet
    )
  end

  @spec add_response(%Context{response: Response.t()}, Pummpcomm.Session.Packet.t()) :: %Context{
          response: Response.t()
        }
  def add_response(context = %Context{response: response}, response_packet) do
    case Response.add_packet(response, response_packet) do
      {:ok, response} -> %{context | response: response}
      {:error, reason} -> %{context | error: reason}
    end
  end

  @doc """
  Marks ack as received in `context`
  """
  @spec received_ack(t) :: %Context{received_ack: true}
  def received_ack(context = %Context{}) do
    %{context | received_ack: true}
  end

  @doc """
  Mark params from `context` `command` as sent
  """
  @spec sent_params(t) :: %Context{sent_params: true}
  def sent_params(context = %Context{}) do
    %{context | sent_params: true}
  end
end
