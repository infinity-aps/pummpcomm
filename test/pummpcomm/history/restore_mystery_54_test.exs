defmodule Pummpcomm.History.RestoreMystery54Test do
  use ExUnit.Case

  test "Restore Mystery 54" do
    {:ok, history_page} = Base.decode16("54FC0040208108FFFCFF00F05000FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFFFCFFFCFF00F05000FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF4601")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:restore_mystery_54, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
