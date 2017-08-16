defmodule Pummpcomm.Driver.WriteCgmTimestampTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.WriteCgmTimestamp

  doctest WriteCgmTimestamp

  test "writing a cgm timestamp results in an ack", %{pump_serial: pump_serial} do
    assert {:ok, %{received_ack: true}} = pump_serial |> WriteCgmTimestamp.make() |> PumpExecutor.execute()
  end
end
