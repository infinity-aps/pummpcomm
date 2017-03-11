defmodule Pummpcomm.History.SelfTestTest do
  use ExUnit.Case

  test "Self Test" do
    {:ok, history_page} = Base.decode16("200006DF12190F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:self_test, %{timestamp: ~N[2015-03-25 18:31:06], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
