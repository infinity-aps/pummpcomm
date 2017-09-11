defmodule Pummpcomm.Driver.ReadCarbRatiosTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Exchange.ReadPumpModel
  alias Pummpcomm.Session.Exchange.ReadCarbRatios

  doctest ReadCarbRatios

  test "ReadCarbRatios results in Map", %{pump_serial: pump_serial} do
    {:ok, pump_model_context} = pump_serial |> ReadPumpModel.make() |> PumpExecutor.execute()
    %{model_number: model_number} = ReadPumpModel.decode(pump_model_context.response)

    {:ok, context} = pump_serial |> ReadCarbRatios.make() |> PumpExecutor.execute()
    assert {:ok, %{units: _}} = ReadCarbRatios.decode(context.response, model_number)
  end

  test "ReadCarbRatios.decode works on larger carb ratio format" do
    response_data = elem(Base.decode16("010600005A0C00411600411C003522003228003C000000"), 1)
    expected_schedule = [
      %{start: ~T[00:00:00], ratio: 9.0},
      %{start: ~T[06:00:00], ratio: 6.5},
      %{start: ~T[11:00:00], ratio: 6.5},
      %{start: ~T[14:00:00], ratio: 5.3},
      %{start: ~T[17:00:00], ratio: 5.0},
      %{start: ~T[20:00:00], ratio: 6.0}
    ]
    assert {:ok, %{units: :grams, schedule: expected_schedule}} == ReadCarbRatios.decode(%Response{opcode: 0x8A, data: response_data}, 751)
  end

  test "ReadCarbRatios.decode works on smaller carb ratio format" do
    response_data = elem(Base.decode16("0100090C0516051C05220528060000"), 1)
    expected_schedule = [
      %{start: ~T[00:00:00], ratio: 9.0},
      %{start: ~T[06:00:00], ratio: 5.0},
      %{start: ~T[11:00:00], ratio: 5.0},
      %{start: ~T[14:00:00], ratio: 5.0},
      %{start: ~T[17:00:00], ratio: 5.0},
      %{start: ~T[20:00:00], ratio: 6.0}
    ]
    assert {:ok, %{units: :grams, schedule: expected_schedule}} == ReadCarbRatios.decode(%Response{opcode: 0x8A, data: response_data}, 722)
  end
end
