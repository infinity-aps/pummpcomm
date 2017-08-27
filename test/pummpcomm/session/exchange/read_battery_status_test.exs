defmodule Pummpcomm.Driver.ReadBatteryStatusTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.ReadBatteryStatus

  doctest ReadBatteryStatus

  test "ReadBatteryStatus results in indicator and voltage", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> ReadBatteryStatus.make() |> PumpExecutor.execute()
    assert {:ok, %{indicator: _, voltage: _}} = ReadBatteryStatus.decode(context.response)
  end
end
