defmodule Pummpcomm.Session.PumpFake do
  use GenServer

  @moduledoc """
  Fakes `Pummpcomm.Session`
  """

  alias Pummpcomm.Cgm

  def start_link(_pump_serial, local_timezone) do
    GenServer.start_link(__MODULE__, local_timezone, name: __MODULE__)
  end

  def get_current_cgm_page do
    {:ok, %{glucose: 32, isig: 32, page_number: 10}}
  end

  # returns 4 sensor glucose values starting at 3 minutes ago
  def read_cgm_page(page), do: GenServer.call(__MODULE__, {:read_cgm_page, page})
  def read_history_page(page), do: GenServer.call(__MODULE__, {:read_history_page, page})

  def write_cgm_timestamp, do: :ok

  def handle_call({:read_cgm_page, 10}, _from, local_timezone) do
    {:reply, fake_rolling_cgm(local_timezone), local_timezone}
  end

  def handle_call({:read_history_page, 0}, _from, local_timezone) do
    events = [{:bg_received,
               %{amount: 87, meter_link_id: "AAAAAA", timestamp: ~N[2017-08-04 23:54:01]}},
              {:result_daily_total, %{strokes: 0, timestamp: ~N[2017-08-05 00:00:00], units: 0.0}},
              {:daily_total_523, %{timestamp: ~N[2017-08-05 00:00:00]}},
              {:null_byte, %{}}]
    |> Enum.map(fn (entry) -> shift_history(entry, history_page_offset(local_timezone)) end)

    {:reply, {:ok, events}, local_timezone}
  end

  def handle_call({:read_history_page, 1}, _from, local_timezone) do
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
    |> Enum.map(fn (entry) -> shift_history(entry, history_page_offset(local_timezone)) end)

    {:reply, {:ok, events}, local_timezone}
  end

  defp history_page_offset(local_timezone) do
    Timex.diff(DateTime.to_naive(Timex.now(local_timezone)), ~N[2017-08-05 00:00:00], :seconds)
  end

  defp shift_history({event_type, event_data = %{timestamp: timestamp}}, offset) do
    shifted_time = Timex.shift(timestamp, seconds: offset)
    {event_type, %{event_data | timestamp: shifted_time}}
  end
  defp shift_history(event, _), do: event

  #returns between 1-2 days of actual cgm data time shifted forward so that it's realistic
  @cgm_binary elem(Base.decode16("514D484645433F133A36333155910539800E302F2C7D1311050B810F2C2D3034373D3F3E3C3A3837353332302E2D2A2B2D28262626252423222222222323242425252423242625242321201F1E1D1D1D1D1D1D1C252F2B2D2D2D2D2D2E2E2C2A2A2929292929292B2C2E2E2C2A2B2D2D2D2C2B292828282828272727262626272828292D30312D2A2C2F3336363613380000011105318A10361105318A08322F2E2D29261323222120201F1E1F22201F1F1F1E1D689105268C0E1E1F2A751A1105328C0F1105318C082E33383B3D3D3D3D3C3C3D3F3F403F3F444B50565F677B9105298E0E0000011105298E101105278E0869645F4388131105018F0F3E1105048F0813393A3B38332F2D2D2E323538383837342D2F2F303335373737373533302E2D2E2E313232333332312F2D2C28201C1B1E202222211F1D1C1E1C1D1F232A3033322E2B2B2E3033333436373B3F42413E3937373533312F2F30313333302D292A2B2E3235383B3C1145229708110527970B112527970B1145229708112527970D00036F91052B970E110527970801030103350D14110537970F11053697083400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000BFD8") , 1)
  def fake_rolling_cgm(local_timezone) do
    today_midnight = local_timezone |> Timex.now() |> Timex.to_date |> Timex.to_naive_datetime
    yesterday_midnight = today_midnight |> Timex.shift(days: -1)
    yesterday = @cgm_binary |> Cgm.decode() |> offset_and_trim_cgm(yesterday_midnight, local_timezone)
    today = @cgm_binary |> Cgm.decode() |> offset_and_trim_cgm(today_midnight, local_timezone)
    {:ok, yesterday ++ today}
  end

  defp offset_and_trim_cgm({:ok, entries}, date_offset, local_timezone) do
    now = local_timezone |> Timex.now() |> DateTime.to_naive
    entries
    |> Enum.map(fn(entry = {entry_type, entry_data}) ->
      case Map.get(entry_data, :timestamp) do
        nil -> entry
        timestamp ->
          day_offset = Timex.diff(date_offset, timestamp |> Timex.to_date, :days)
          {entry_type, %{entry_data | timestamp: Timex.shift(timestamp, days: day_offset)}}
      end
    end)
    |> Enum.filter(fn({entry_type, entry_data}) ->
      case Map.get(entry_data, :timestamp) do
        nil -> entry_type != :null_byte
        timestamp -> Timex.before?(timestamp, now)
      end
    end)
  end
end
