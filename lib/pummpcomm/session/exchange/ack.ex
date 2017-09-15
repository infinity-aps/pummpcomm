defmodule Pummpcomm.Session.Exchange.Ack do
  @moduledoc """
  Acknowledge an exchange with pump during a session
  """

  alias Pummpcomm.Session.Command

  # Constants

  @opcode 0x06

  # Functions

  @doc """
  Makes `Pummpcomm.Session.Command.t` to acknowledge `Pummpcomm.Session.Response.t` from pump with `pump_serial`
  """
  @spec make(Command.pump_serial) :: Command.t
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
