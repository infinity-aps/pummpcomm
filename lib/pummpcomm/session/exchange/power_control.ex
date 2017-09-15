defmodule Pummpcomm.Session.Exchange.PowerControl do
  @moduledoc """
  Wakes up pump for communications
  """

  alias Pummpcomm.Session.Command

  # Constants

  @opcode 0x5D

  # Functions

  @doc """
  Makes `Pummpcomm.Session.Command.t` to wake up pump with `pump_serial` for `minutes`
  """
  @spec make(Command.pump_serial) :: %Command{retries: 0, params: <<_ :: 8>>}
  @spec make(Command.pump_serial, minutes :: pos_integer) :: %Command{retries: 0, params: <<_ :: 8>>}
  def make(pump_serial, minutes \\ 10) do
    %Command{opcode: @opcode, pump_serial: pump_serial, retries: 0, params: <<minutes::size(8)>>}
  end
end
