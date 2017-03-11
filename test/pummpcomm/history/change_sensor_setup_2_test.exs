defmodule Pummpcomm.History.ChangeSensorSetup2Test do
  use ExUnit.Case

  test "Change Sensor Setup 2 - 1" do
    {:ok, history_page} = Base.decode16("5000004000810821011E003C14001E3C20A4D4B44680002820011E003C14001E3CFFFFFFB446000028")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{ supports_low_suspend: true })
    assert {:change_sensor_setup_2, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Change Sensor Setup 2 - 2" do
    #TODO find real data
    {:ok, history_page} = Base.decode16("5000004000810821011E003C14001E3C20A4D4B44680002820011E003C14001E3CFFFFFFB4")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{ supports_low_suspend: false })
    assert {:change_sensor_setup_2, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
