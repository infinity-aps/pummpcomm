defmodule Pummpcomm.Session.Exchange.ReadCgmPage do
  @moduledoc """
  Reads a CGM page.  To get the valid range of `page`, use `Pummpcomm.Session.Exchange.GetCurrentCgmPage`.
  """

  alias Pummpcomm.Cgm
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x9A

  # Functions

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to `Pummpcomm.Cgm.event`s on page requested in `make/2`
  `Pummpcomm.Session.Command.t`
  """
  @spec decode(Response.t()) :: {:ok, [Cgm.event()]}
  def decode(%Response{opcode: @opcode, data: data}) do
    Cgm.decode(data)
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read `page` from CGM attached to pump with `pump_serial`. To get the valid
  range of `page`, use `Pummpcomm.Session.Exchange.GetCurrentCgmPage`.  Pages count up from `1`, so it is not possible
  to determine the current page and the range of valid pages without using
  `Pummpcomm.Session.Exchange.GetCurrentCgmPage` first.
  """
  @spec make(Command.pump_serial(), page :: non_neg_integer) :: %Command{timeout: 5000}
  def make(pump_serial, page) do
    %Command{opcode: @opcode, pump_serial: pump_serial, params: <<page::size(32)>>, timeout: 5000}
  end
end
