defmodule Pummpcomm.Driver.ReadHistoryPageTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.ReadPumpModel
  alias Pummpcomm.Session.Exchange.ReadHistoryPage

  doctest ReadHistoryPage

  test "Reading a history page results in decoded events", %{pump_serial: pump_serial} do
    {:ok, pump_model_context} = pump_serial |> ReadPumpModel.make() |> PumpExecutor.execute()
    %{model_number: model_number} = ReadPumpModel.decode(pump_model_context.response)

    {:ok, context} = pump_serial |> ReadHistoryPage.make(0) |> PumpExecutor.execute()
    {:ok, events} = ReadHistoryPage.decode(context.response, model_number)

    assert is_list(events)
  end
end
