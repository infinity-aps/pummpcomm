defmodule Pummpcomm.History.ChangeAudioBolusTest do
  use ExUnit.Case

  test "Change Audio Bolus" do
    {:ok, history_page} = Base.decode16("5F0D78380F050F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_audio_bolus, %{timestamp: ~N[2015-04-05 15:56:56], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
