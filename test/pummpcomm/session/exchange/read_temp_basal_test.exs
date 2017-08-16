defmodule Pummpcomm.Driver.ReadTempBasalTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Exchange.ReadTempBasal

  doctest ReadTempBasal

  test "ReadTempBasal results in Map", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> ReadTempBasal.make() |> PumpExecutor.execute()
    assert %{} = ReadTempBasal.decode(context.response)
  end

  test "ReadTempBasal decodes unset temp_basal" do
    result = ReadTempBasal.decode(%Response{opcode: 0x98, data: <<0x00, 0x00, 0x0000::16, 0x0000::16>>})
    assert %{type: :absolute, rate: 0.000, duration: 0} = result
  end

  test "ReadTempBasal decodes absolute temp_basal of 0" do
    result = ReadTempBasal.decode(%Response{opcode: 0x98, data: <<0x00, 0x00, 0x0000::16, 0x003C::16>>})
    assert %{type: :absolute, rate: 0.0, duration: 60} = result
  end

  test "ReadTempBasal decodes positive absolute temp_basal" do
    result = ReadTempBasal.decode(%Response{opcode: 0x98, data: <<0x00, 0x00, 0x0001::16, 0x001E::16>>})
    assert %{type: :absolute, rate: 0.025, duration: 30} = result
  end

  test "ReadTempBasal decodes percent temp_basal" do
    result = ReadTempBasal.decode(%Response{opcode: 0x98, data: <<0x01, 0x5F, 0x0000::16, 0x001E::16>>})
    assert %{type: :percent, rate: 95, duration: 30} = result
  end
end
