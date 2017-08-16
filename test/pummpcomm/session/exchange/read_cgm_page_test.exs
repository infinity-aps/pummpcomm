defmodule Pummpcomm.Driver.ReadCgmPageTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.GetCurrentCgmPage
  alias Pummpcomm.Session.Exchange.ReadCgmPage

  doctest ReadCgmPage

  test "Reading a cgm page results in decoded events", %{pump_serial: pump_serial} do
    with {:ok, context} <- pump_serial |> GetCurrentCgmPage.make() |> PumpExecutor.execute(),
         %{page_number: page_number} <- GetCurrentCgmPage.decode(context.response) do
      {:ok, context} = pump_serial |> ReadCgmPage.make(page_number) |> PumpExecutor.execute()
      {:ok, events} = ReadCgmPage.decode(context.response)
      assert is_list(events)
    end
  end
end
