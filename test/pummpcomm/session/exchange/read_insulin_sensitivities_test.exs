defmodule Pummpcomm.Driver.ReadInsulinSensitivitiesTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Exchange.ReadInsulinSensitivities

  doctest ReadInsulinSensitivities

  test "ReadInsulinSensitivities results in units and sensitivities", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> ReadInsulinSensitivities.make() |> PumpExecutor.execute()
    assert {:ok, %{units: _, sensitivities: _}} = ReadInsulinSensitivities.decode(context.response)
  end

  test "ReadInsulinSensitivities.decode returns correct information" do
    {:ok, response_data} = Base.decode16("01002610222A26000000000000000000000000000000")
    expected_sensitivities = [
      %{start: ~T[00:00:00], sensitivity: 38},
      %{start: ~T[08:00:00], sensitivity: 34},
      %{start: ~T[21:00:00], sensitivity: 38}
    ]
    assert {:ok, %{units: "mg/dL", sensitivities: expected_sensitivities}} == ReadInsulinSensitivities.decode(%Response{opcode: 0x8B, data: response_data})
  end
end
