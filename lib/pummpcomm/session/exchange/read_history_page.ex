defmodule Pummpcomm.Session.Exchange.ReadHistoryPage do
  @moduledoc """
  Reads a page of `Pummpcomm.History`
  """

  alias Pummpcomm.History
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x80

  # Functions

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to records on page
  """
  @spec decode(Response.t(), Pummpcomm.PumpModel.pump_model()) :: {:ok, [%{}]}
  def decode(%Response{opcode: @opcode, data: data}, pump_model) do
    History.decode(data, pump_model)
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read a single history page
  """
  @spec make(Command.pump_serial(), page :: non_neg_integer) :: Command.t()
  def make(pump_serial, page) do
    %Command{opcode: @opcode, pump_serial: pump_serial, params: <<page::size(8)>>, timeout: 5000}
  end
end
