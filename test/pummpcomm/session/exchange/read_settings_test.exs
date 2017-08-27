defmodule Pummpcomm.Driver.ReadSettingsTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Response
  alias Pummpcomm.Session.Exchange.ReadSettings

  doctest ReadSettings

  test "ReadSettings results in a Map", %{pump_serial: pump_serial} do
    {:ok, context} = pump_serial |> ReadSettings.make() |> PumpExecutor.execute()
    assert {:ok, %{max_bolus: _, max_basal: _, selected_basal_profile: _, insulin_action_curve_hours: _}} = ReadSettings.decode(context.response)
  end

  test "ReadSettings decodes the correct information for smaller format" do
    {:ok, response_data} = Base.decode16("000200010100C80050010101000000640103001400190100")
    assert {:ok, %{max_bolus: 20.0, max_basal: 2.0, selected_basal_profile: :profile_a, insulin_action_curve_hours: 3}} == ReadSettings.decode(%Response{opcode: 0xC0, data: response_data})
  end
end
