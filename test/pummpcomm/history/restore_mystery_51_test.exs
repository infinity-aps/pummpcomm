defmodule Pummpcomm.History.RestoreMystery51Test do
  use ExUnit.Case

  test "Restore Mystery 51" do
    {:ok, history_page} = Base.decode16("51020040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:restore_mystery_51, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
