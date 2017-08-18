defmodule Pummpcomm.Driver.SetTempBasalTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.SetTempBasal
  alias Pummpcomm.Session.Exchange.ReadTempBasal

  doctest SetTempBasal

  test "SetTempBasal does the thing for which it is named", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> SetTempBasal.make(units_per_hour: 1.05, duration: 30, type: :absolute) |> PumpExecutor.execute()
    assert :ok == SetTempBasal.decode(context.response)

    {:ok, verify_context} = pump_serial |> ReadTempBasal.make() |> PumpExecutor.execute()
    assert %{units_per_hour: 1.05, duration: 30, type: :absolute} == ReadTempBasal.decode(verify_context.response)
  end
end
