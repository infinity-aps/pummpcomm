defmodule Pummpcomm.Session.PumpFake do
  def get_current_cgm_page do
    %{glucose: 32, isig: 32, page_number: 10}
  end

  # returns 4 sensor glucose values starting at 3 minutes ago
  def read_cgm_page(10) do
    {:ok,
     Enum.map(3..0, fn(item) -> generate_sgv((item * 5) + 3) end)
    }
  end

  def read_cgm_page(9) do
    timestamp = {:sensor_timestamp, %{event_type: :page_end, raw: <<16, 40, 182, 20, 8>>, timestamp: time_for_minutes_back(23)}}
    {
      :ok,
      Enum.map(13..4, fn(item) -> generate_sgv((item * 5) + 3) end) ++ [timestamp]
    }
  end

  def write_cgm_timestamp(), do: :ok

  def read_history_page(0) do
    events = [{:bg_received,
               %{amount: 87, meter_link_id: "AAAAAA", timestamp: ~N[2017-08-04 23:54:01]}},
              {:result_daily_total, %{strokes: 0, timestamp: ~N[2017-08-05 00:00:00], units: 0.0}},
              {:daily_total_523, %{timestamp: ~N[2017-08-05 00:00:00]}},
              {:null_byte, %{}}]
    |> Enum.map(fn (entry) -> shift_history(entry, history_page_offset()) end)

    {:ok, events}
  end

  def read_history_page(1) do
    events = [{:alarm_sensor,
               %{alarm_type: "High Glucose", amount: 151, timestamp: ~N[2017-08-03 17:41:45]}},
              {:alarm_sensor,
               %{alarm_type: "Cal Reminder", timestamp: ~N[2017-08-03 19:08:00]}},
              {:cal_bg_for_ph,
               %{amount: 117, timestamp: ~N[2017-08-03 20:15:11]}},
              {:bg_received,
               %{amount: 117, meter_link_id: "AAAAAA", timestamp: ~N[2017-08-03 20:15:11]}},
              {:bolus_wizard_estimate,
               %{bg: 117, bg_target_high: 115, bg_target_low: 80, bolus_estimate: 0.05,
                 carb_ratio: 6.0, carbohydrates: 0, correction_estimate: 0.2,
                 food_estimate: 0.0, insulin_sensitivity: 34,
                 timestamp: ~N[2017-08-03 20:15:27],
                 unabsorbed_insulin_total: 0.0}},
              {:bolus_normal,
               %{amount: 0.025, duration: 0, programmed: 0.025,
                 timestamp: ~N[2017-08-03 20:15:27], type: :normal, unabsorbed_insulin: 0.0}},
              {:result_daily_total, %{strokes: 1, timestamp: ~N[2017-08-04 00:00:00], units: 0.025}},
              {:daily_total_523, %{timestamp: ~N[2017-08-04 00:00:00]}},
              {:alarm_sensor,
               %{alarm_type: "Cal Reminder", timestamp: ~N[2017-08-04 07:15:00]}},
              {:alarm_sensor,
               %{alarm_type: "Meter BG Now", timestamp: ~N[2017-08-04 08:15:00]}},
              {:cal_bg_for_ph,
               %{amount: 87, timestamp: ~N[2017-08-04 08:16:45]}},
              {:cal_bg_for_ph,
               %{amount: 103, timestamp: ~N[2017-08-04 17:50:07]}},
              {:bg_received,
               %{amount: 103, meter_link_id: "AAAAAA", timestamp: ~N[2017-08-04 17:50:07]}},
              {:alarm_sensor,
               %{alarm_type: "High Glucose", amount: 157, timestamp: ~N[2017-08-04 23:15:09]}},
              {:null_byte, %{}}]
    |> Enum.map(fn (entry) -> shift_history(entry, history_page_offset()) end)

    {:ok, events}
  end

  defp history_page_offset do
    Timex.diff(DateTime.to_naive(Timex.local), ~N[2017-08-05 00:00:00], :seconds)
  end

  defp shift_history({event_type, event_data = %{timestamp: timestamp}}, offset) do
    shifted_time = Timex.shift(timestamp, seconds: offset)
    {event_type, %{event_data | timestamp: shifted_time}}
  end
  defp shift_history(event, _), do: event

  defp generate_sgv(minutes_back) do
    {:sensor_glucose_value,
     %{sgv: 200 - minutes_back, timestamp: time_for_minutes_back(minutes_back)}}
  end

  defp time_for_minutes_back(minutes_back) do
    Timex.local |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive
  end
end
