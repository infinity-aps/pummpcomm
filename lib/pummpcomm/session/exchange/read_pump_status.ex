defmodule Pummpcomm.Session.Exchange.ReadPumpStatus do
  @moduledoc """
  Reads status of pump: whether it's bolusing or suspended.
  """

  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0xCE

  # Functions

  @doc """
  Decodes `Pummpcomm.Session.Response.t` from `make/1` `Pummpcomm.Session.Command.t` to whether pump is currently
  bolusing or suspended.
  """
  @spec decode(Response.t()) :: {:ok, %{bolusing: boolean, suspended: boolean}}
  def decode(%Response{opcode: @opcode, data: <<_::8, bolusing::8, suspended::8, _rest::binary>>}) do
    {:ok, %{bolusing: decode_bool(bolusing), suspended: decode_bool(suspended)}}
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to check if pump is currently bolusing or suspended.
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  ## Private Functions

  defp decode_bool(0), do: false
  defp decode_bool(_), do: true
end
