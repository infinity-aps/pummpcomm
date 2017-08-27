defmodule Pummpcomm.Driver.GetCurrentCgmPageTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.GetCurrentCgmPage

  doctest GetCurrentCgmPage

  test "get current cgm page results in a number", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> GetCurrentCgmPage.make() |> PumpExecutor.execute()
    {:ok, %{page_number: page_number}} = GetCurrentCgmPage.decode(context.response)
    assert is_integer(page_number)
  end
end
