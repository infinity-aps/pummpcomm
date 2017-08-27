defmodule Pummpcomm.Driver.ReadBgTargets do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Exchange.ReadBgTargets

  doctest ReadBgTargets

  test "ReadBgTargets results in a Map", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> ReadBgTargets.make() |> PumpExecutor.execute()
    assert {:ok, %{units: _, targets: _}} = ReadBgTargets.decode(context.response)
  end

  test "ReadBgTargets.decode has correct information" do
    {:ok, response_data} = Base.decode16("0100507301507300000000")
    expected_targets = [
      %{start: ~T[00:00:00], bg_low: 80, bg_high: 115},
      %{start: ~T[00:30:00], bg_low: 80, bg_high: 115}
    ]
    assert {:ok, %{units: "mg/dL", targets: expected_targets}} == ReadBgTargets.decode(%Response{opcode: 0x9F, data: response_data})
  end
end
