defmodule Pummpcomm.History.PrimeTest do
  use ExUnit.Case

  test "Prime" do
    {:ok, history_page} = Base.decode16("030000000A4A2A33040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    expected_event_info = %{
      programmed_amount: 0.0,
      amount: 1.0,
      prime_type: :manual,
      timestamp: ~N[2015-04-04 19:42:10],
      raw: history_page
    }
    assert {:prime, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
