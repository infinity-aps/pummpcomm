defmodule Pummpcomm.Driver.ReadPumpStatusTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.ReadPumpStatus

  doctest ReadPumpStatus

  test "ReadPumpStatus results in status, bolusing, and suspended", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> ReadPumpStatus.make() |> PumpExecutor.execute()
    assert {:ok, %{bolusing: _, suspended: _}} = ReadPumpStatus.decode(context.response)
  end
end
