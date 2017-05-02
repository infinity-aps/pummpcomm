defmodule Pummpcomm.History.BasalProfileStartTest do
  use ExUnit.Case

  test "Basal Profile Start - 1" do
    {:ok, history_page} = Base.decode16("7B00572A13040F000400")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    expected_event_info = %{
      offset: 0,
      rate: 0.1,
      profile_index: 0,
      timestamp: ~N[2015-04-04 19:42:23],
      raw: history_page
    }
    assert {:basal_profile_start, ^expected_event_info} = Enum.at(decoded_events, 0)
  end

  test "Basal Profile Start - 2" do
    {:ok, history_page} = Base.decode16("7B066F3712050F253000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    expected_event_info = %{
      offset: 66600000,
      rate: 1.2,
      profile_index: 6,
      timestamp: ~N[2015-04-05 18:55:47],
      raw: history_page
    }
    assert {:basal_profile_start, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
