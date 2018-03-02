defmodule Pummpcomm.Session.Exchange.ReadTime do
  @moduledoc """
  Reads pump's current time
  """

  alias Pummpcomm.Session.{Command, Response}
  alias Pummpcomm.DateDecoder

  # Constants

  @opcode 0x70

  # Functions

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to `NaiveDateTime.t` for the pump's current time
  """
  @spec decode(Response.t()) :: {:ok, NaiveDateTime.t()} | {:error, :invalid_time}
  def decode(%Response{opcode: @opcode, data: <<encoded_date::binary-size(7), _::binary>>}) do
    DateDecoder.decode_full_datetime(encoded_date)
  end

  @doc """
  Make `Pummpcomm.Session.Command.t` to get pump with `pump_serial`'s current time
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
