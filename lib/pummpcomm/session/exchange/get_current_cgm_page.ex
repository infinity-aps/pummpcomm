defmodule Pummpcomm.Session.Exchange.GetCurrentCgmPage do
  @moduledoc """
  Read the current `page_number` for CGM pages and `page_count` back of `glucose` and `isig` is available when
  using `Pummpcomm.Session.Exchange.ReadCgmPage`.
  """

  alias Pummpcomm.Session.{Command, Response}

  # CONSTANTS

  @opcode 0xCD

  # Types

  @typedoc """
  The number of pages back from the current `page_number` stored for either glucose or isig.  Think of the data as a
  [ring buffer](https://en.wikipedia.org/wiki/Ring_buffer) with only `page_count` number of pages stored, but the
  overall reported `page_number` increasing, so there is less chance of page confusion when combine long stretches of
  pages.
  """
  @type page_count :: 0..32

  @typedoc """
  The current page number for CGM data.
  """
  @type page_number :: non_neg_integer

  # Functions

  @doc """
  Decodes the current `page_number` for CGM pages and `page_count` back of `glucose` and `isig` is available when
  using `Pummpcomm.Session.Exchange.ReadCgmPage`.
  """
  @spec decode(Response.t()) ::
          {:ok, %{page_number: page_number, glucose: page_count, isig: page_count}}
  def decode(%Response{
        opcode: @opcode,
        data: <<page_number::size(32), glucose::size(16), isig::size(16), _rest::binary>>
      }) do
    {:ok, %{page_number: page_number, glucose: glucose, isig: isig}}
  end

  @doc """
  `Pummpcomm.Session.Command` to get current CGM page from pump with `pump_serial`.
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
