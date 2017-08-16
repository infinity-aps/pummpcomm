defmodule Pummpcomm.Driver.ReadRemainingInsulinTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.PumpModel
  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Exchange.ReadPumpModel
  alias Pummpcomm.Session.Exchange.ReadRemainingInsulin

  doctest ReadRemainingInsulin

  test "ReadRemainingInsulin results in units remaining", %{pump_serial: pump_serial} do
    with {:ok, pump_model_context} <- pump_serial |> ReadPumpModel.make() |> PumpExecutor.execute(),
         %{model_number: model_number} <- ReadPumpModel.decode(pump_model_context.response),
         %{strokes_per_unit: strokes_per_unit} <- PumpModel.pump_options(model_number) do
      {:ok, context} = pump_serial |> ReadRemainingInsulin.make() |> PumpExecutor.execute()
      assert %{remaining_insulin: _} = ReadRemainingInsulin.decode(context.response, strokes_per_unit)
    end
  end

  test "decode on older pump uses 10 strokes per unit" do
    result = ReadRemainingInsulin.decode(%Response{opcode: 0x73, data: <<0x1BC5::16, 0x0000::16>>}, 10)
    assert %{remaining_insulin: 7109 / 10} = result
  end

  test "decode on newer pump uses 40 strokes per unit" do
    result = ReadRemainingInsulin.decode(%Response{opcode: 0x73, data: <<0x0000::16, 0x1BC5::16>>}, 40)
    assert %{remaining_insulin: 7109 / 40} = result
  end
end
