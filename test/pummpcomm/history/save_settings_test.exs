defmodule Pummpcomm.History.SaveSettingsTest do
  use ExUnit.Case

  # TODO capture this in real life
  test "Save Settings" do
    {:ok, history_page} = Base.decode16("5D00722713040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:save_settings, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
