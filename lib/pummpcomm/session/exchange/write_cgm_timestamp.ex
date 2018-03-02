defmodule Pummpcomm.Session.Exchange.WriteCgmTimestamp do
  @moduledoc false

  alias Pummpcomm.Session.Command

  # Constants

  @opcode 0x28

  # Functions

  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
