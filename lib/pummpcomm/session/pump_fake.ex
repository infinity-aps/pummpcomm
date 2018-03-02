defmodule Pummpcomm.Session.PumpFake do
  use GenServer

  @moduledoc """
  Fakes `Pummpcomm.Session`
  """

  def start_link(_pump_serial, local_timezone) do
    GenServer.start_link(__MODULE__, local_timezone, name: __MODULE__)
  end

  def init(local_timezone) do
    {:ok, local_timezone}
  end

  def get_current_cgm_page do
    {:ok, %{glucose: 32, isig: 32, page_number: 10}}
  end

  def get_model_number, do: {:ok, 722}

  def read_bg_targets,
    do: {:ok, %{units: "mg/dL", targets: [%{bg_high: 120, bg_low: 80, start: ~T[00:00:00]}]}}

  def read_carb_ratios,
    do: {:ok, %{units: :grams, schedule: [%{ratio: 15.0, start: ~T[00:00:00]}]}}

  def read_cgm_page(page), do: GenServer.call(__MODULE__, {:read_cgm_page, page})
  def read_history_page(page), do: GenServer.call(__MODULE__, {:read_history_page, page})

  def read_insulin_sensitivities,
    do: {:ok, units: "mg/dL", sensitivities: [%{sensitivity: 40, start: ~T[00:00:00]}]}

  def read_settings,
    do:
      {:ok,
       insulin_action_curve_hours: 3,
       max_basal: 3.0,
       max_bolus: 15.0,
       selected_basal_profile: :standard}

  def read_std_basal_profile, do: {:ok, %{schedule: [%{rate: 1.4, start: ~T[00:00:00]}]}}
  def read_temp_basal, do: {:ok, %{type: :absolute, units_per_hour: 3.0, duration: 30}}
  def read_time, do: {:ok, Timex.now()}

  def set_temp_basal(units_per_hour: units_per_hour, duration_minutes: duration, type: type) do
    {:ok, %{type: type, units_per_hour: units_per_hour, duration: duration}}
  end

  def write_cgm_timestamp, do: :ok

  def handle_call({:read_cgm_page, 10}, _from, local_timezone) do
    {:reply, fake_rolling_cgm(local_timezone), local_timezone}
  end

  def handle_call({:read_history_page, 0}, _from, local_timezone) do
    {:reply, fake_rolling_history(local_timezone), local_timezone}
  end

  def fake_rolling_history(local_timezone) do
    today_midnight = local_timezone |> Timex.now() |> Timex.to_date() |> Timex.to_naive_datetime()
    yesterday_midnight = today_midnight |> Timex.shift(days: -1)

    yesterday =
      history_entries() |> Enum.reverse()
      |> offset_and_trim_history(yesterday_midnight, local_timezone)

    today =
      history_entries() |> Enum.reverse()
      |> offset_and_trim_history(today_midnight, local_timezone)

    {:ok, yesterday ++ today}
  end

  defp offset_and_trim_history(entries, date_offset, local_timezone) do
    now = local_timezone |> Timex.now() |> DateTime.to_naive()

    entries
    |> Enum.map(fn entry = {entry_type, entry_data} ->
      case Map.get(entry_data, :timestamp) do
        nil ->
          entry

        timestamp ->
          day_offset = Timex.diff(date_offset, timestamp |> Timex.to_date(), :days)
          {entry_type, %{entry_data | timestamp: Timex.shift(timestamp, days: day_offset)}}
      end
    end)
    |> Enum.filter(fn {entry_type, entry_data} ->
      case Map.get(entry_data, :timestamp) do
        nil -> entry_type != :null_byte
        timestamp -> Timex.before?(timestamp, now)
      end
    end)
  end

  # returns between 1-2 days of actual cgm data time shifted so that it's realistic
  def fake_rolling_cgm(local_timezone) do
    today_midnight = local_timezone |> Timex.now() |> Timex.to_date() |> Timex.to_naive_datetime()
    yesterday_midnight = today_midnight |> Timex.shift(days: -1)

    yesterday =
      sgv_entries() |> Enum.reverse() |> offset_and_trim_cgm(yesterday_midnight, local_timezone)

    today = sgv_entries() |> Enum.reverse() |> offset_and_trim_cgm(today_midnight, local_timezone)
    {:ok, yesterday ++ today}
  end

  defp offset_and_trim_cgm(entries, date_offset, local_timezone) do
    now = local_timezone |> Timex.now() |> DateTime.to_naive()

    entries
    |> Enum.map(fn entry = {entry_type, entry_data} ->
      case Map.get(entry_data, :timestamp) do
        nil ->
          entry

        timestamp ->
          day_offset = Timex.diff(date_offset, timestamp |> Timex.to_date(), :days)
          {entry_type, %{entry_data | timestamp: Timex.shift(timestamp, days: day_offset)}}
      end
    end)
    |> Enum.filter(fn {entry_type, entry_data} ->
      case Map.get(entry_data, :timestamp) do
        nil -> entry_type != :null_byte
        timestamp -> Timex.before?(timestamp, now)
      end
    end)
  end

  defp history_entries do
    [
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 45, 185, 23, 83, 18>>, timestamp: ~N[2018-02-19 23:57:45]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 45, 185, 23, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 23:57:45]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 44, 173, 23, 83, 18>>, timestamp: ~N[2018-02-19 23:45:44]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 44, 173, 23, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 23:45:44]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 34, 162, 23, 83, 18>>, timestamp: ~N[2018-02-19 23:34:34]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 34, 162, 23, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 23:34:34]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 46, 134, 23, 83, 18>>, timestamp: ~N[2018-02-19 23:06:46]}},
      {:temp_basal,
       %{
         rate: 1.1,
         rate_type: :absolute,
         raw: <<51, 44, 46, 134, 23, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 23:06:46]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 35, 183, 22, 83, 18>>, timestamp: ~N[2018-02-19 22:55:35]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 35, 183, 22, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 22:55:35]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 59, 167, 22, 83, 18>>, timestamp: ~N[2018-02-19 22:39:59]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 59, 167, 22, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 22:39:59]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 59, 150, 22, 83, 18>>, timestamp: ~N[2018-02-19 22:22:59]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 59, 150, 22, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 22:22:59]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 54, 133, 22, 83, 18>>, timestamp: ~N[2018-02-19 22:05:54]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 54, 133, 22, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 22:05:54]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 46, 168, 21, 83, 18>>, timestamp: ~N[2018-02-19 21:40:46]}},
      {:temp_basal,
       %{
         rate: 3.5,
         rate_type: :absolute,
         raw: <<51, 140, 46, 168, 21, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 21:40:46]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 31, 158, 21, 83, 18>>, timestamp: ~N[2018-02-19 21:30:31]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 31, 158, 21, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 21:30:31]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 52, 157, 21, 83, 18>>, timestamp: ~N[2018-02-19 21:29:52]}},
      {:temp_basal,
       %{
         rate: 3.5,
         rate_type: :absolute,
         raw: <<51, 140, 52, 157, 21, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 21:29:52]
       }},
      {:bolus_normal,
       %{
         amount: 4.0,
         duration: 0,
         programmed: 4.0,
         raw: <<1, 40, 40, 0, 17, 151, 85, 19, 18>>,
         timestamp: ~N[2018-02-19 21:23:17],
         type: :normal
       }},
      {:bolus_wizard_estimate,
       %{
         bg: 280,
         bg_target_high: 110,
         bg_target_low: 90,
         bolus_estimate: 0.0,
         carb_ratio: 6,
         carbohydrates: 0,
         correction_estimate: 5.6,
         food_estimate: 0.0,
         insulin_sensitivity: 30,
         raw: <<91, 24, 17, 151, 21, 19, 18, 0, 81, 6, 30, 90, 56, 0, 0, 0, 81, 0, 0, 110>>,
         timestamp: ~N[2018-02-19 21:23:17],
         unabsorbed_insulin_total: 8.1
       }},
      {:bg_received,
       %{
         amount: 280,
         meter_link_id: "C1774D",
         raw: <<63, 35, 46, 150, 21, 115, 18, 193, 119, 77>>,
         timestamp: ~N[2018-02-19 21:22:46]
       }},
      {:cal_bg_for_ph,
       %{amount: 280, raw: <<10, 24, 46, 150, 53, 115, 146>>, timestamp: ~N[2018-02-19 21:22:46]}},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 9, 146, 21, 83, 18>>, timestamp: ~N[2018-02-19 21:18:09]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 9, 146, 21, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 21:18:09]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 29, 180, 20, 83, 18>>, timestamp: ~N[2018-02-19 20:52:29]}},
      {:temp_basal,
       %{
         rate: 1.1,
         rate_type: :absolute,
         raw: <<51, 44, 29, 180, 20, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 20:52:29]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 49, 169, 20, 83, 18>>, timestamp: ~N[2018-02-19 20:41:49]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 49, 169, 20, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 20:41:49]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 54, 153, 20, 83, 18>>, timestamp: ~N[2018-02-19 20:25:54]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 54, 153, 20, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 20:25:54]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 45, 137, 20, 83, 18>>, timestamp: ~N[2018-02-19 20:09:45]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 45, 137, 20, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 20:09:45]
       }},
      {:bolus_normal,
       %{
         amount: 11.6,
         duration: 0,
         programmed: 11.6,
         raw: <<1, 116, 116, 0, 49, 129, 84, 19, 18>>,
         timestamp: ~N[2018-02-19 20:01:49],
         type: :normal
       }},
      {:bolus_wizard_estimate,
       %{
         bg: 0,
         bg_target_high: 110,
         bg_target_low: 90,
         bolus_estimate: 11.6,
         carb_ratio: 6,
         carbohydrates: 70,
         correction_estimate: 0.0,
         food_estimate: 11.6,
         insulin_sensitivity: 25,
         raw: <<91, 0, 49, 129, 20, 19, 18, 70, 80, 6, 25, 90, 0, 116, 0, 0, 0, 0, 116, 110>>,
         timestamp: ~N[2018-02-19 20:01:49],
         unabsorbed_insulin_total: 0.0
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 37, 179, 19, 83, 18>>, timestamp: ~N[2018-02-19 19:51:37]}},
      {:temp_basal,
       %{
         rate: 2.25,
         rate_type: :absolute,
         raw: <<51, 90, 37, 179, 19, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 19:51:37]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 42, 175, 19, 83, 18>>, timestamp: ~N[2018-02-19 19:47:42]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 42, 175, 19, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 19:47:42]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 8, 175, 19, 83, 18>>, timestamp: ~N[2018-02-19 19:47:08]}},
      {:temp_basal,
       %{
         rate: 1.7,
         rate_type: :absolute,
         raw: <<51, 68, 8, 175, 19, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 19:47:08]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 23, 143, 19, 83, 18>>, timestamp: ~N[2018-02-19 19:15:23]}},
      {:temp_basal,
       %{
         rate: 3.3,
         rate_type: :absolute,
         raw: <<51, 132, 23, 143, 19, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 19:15:23]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 1, 138, 19, 83, 18>>, timestamp: ~N[2018-02-19 19:10:01]}},
      {:temp_basal,
       %{
         rate: 2.55,
         rate_type: :absolute,
         raw: <<51, 102, 1, 138, 19, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 19:10:01]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 0, 132, 19, 83, 18>>, timestamp: ~N[2018-02-19 19:04:00]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 0, 132, 19, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 19:04:00]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 18, 181, 18, 83, 18>>, timestamp: ~N[2018-02-19 18:53:18]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 18, 181, 18, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 18:53:18]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 53, 167, 18, 83, 18>>, timestamp: ~N[2018-02-19 18:39:53]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 53, 167, 18, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 18:39:53]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 21, 156, 18, 83, 18>>, timestamp: ~N[2018-02-19 18:28:21]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 21, 156, 18, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 18:28:21]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 7, 147, 18, 83, 18>>, timestamp: ~N[2018-02-19 18:19:07]}},
      {:temp_basal,
       %{
         rate: 3.5,
         rate_type: :absolute,
         raw: <<51, 140, 7, 147, 18, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 18:19:07]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 46, 141, 18, 83, 18>>, timestamp: ~N[2018-02-19 18:13:46]}},
      {:temp_basal,
       %{
         rate: 1.0,
         rate_type: :absolute,
         raw: <<51, 40, 46, 141, 18, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 18:13:46]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 25, 136, 18, 83, 18>>, timestamp: ~N[2018-02-19 18:08:25]}},
      {:temp_basal,
       %{
         rate: 2.55,
         rate_type: :absolute,
         raw: <<51, 102, 25, 136, 18, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 18:08:25]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 33, 130, 18, 83, 18>>, timestamp: ~N[2018-02-19 18:02:33]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 33, 130, 18, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 18:02:33]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 40, 185, 17, 83, 18>>, timestamp: ~N[2018-02-19 17:57:40]}},
      {:temp_basal,
       %{
         rate: 3.05,
         rate_type: :absolute,
         raw: <<51, 122, 40, 185, 17, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 17:57:40]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 20, 159, 17, 83, 18>>, timestamp: ~N[2018-02-19 17:31:20]}},
      {:temp_basal,
       %{
         rate: 3.5,
         rate_type: :absolute,
         raw: <<51, 140, 20, 159, 17, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 17:31:20]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 10, 147, 17, 83, 18>>, timestamp: ~N[2018-02-19 17:19:10]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 10, 147, 17, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 17:19:10]
       }},
      {:prime,
       %{
         amount: 0.5,
         prime_type: :fixed,
         programmed_amount: 0.5,
         raw: <<3, 0, 5, 0, 5, 5, 144, 17, 19, 18>>,
         timestamp: ~N[2018-02-19 17:16:05]
       }},
      {:prime,
       %{
         amount: 9.6,
         prime_type: :manual,
         programmed_amount: 0.0,
         raw: <<3, 0, 0, 0, 96, 16, 143, 49, 19, 18>>,
         timestamp: ~N[2018-02-19 17:15:16]
       }},
      {:pump_rewind, %{raw: <<33, 0, 26, 139, 17, 19, 18>>, timestamp: ~N[2018-02-19 17:11:26]}},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 15, 136, 17, 83, 18>>, timestamp: ~N[2018-02-19 17:08:15]}},
      {:temp_basal,
       %{
         rate: 2.55,
         rate_type: :absolute,
         raw: <<51, 102, 15, 136, 17, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 17:08:15]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 51, 131, 17, 83, 18>>, timestamp: ~N[2018-02-19 17:03:51]}},
      {:temp_basal,
       %{
         rate: 1.65,
         rate_type: :absolute,
         raw: <<51, 66, 51, 131, 17, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 17:03:51]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 23, 179, 16, 83, 18>>, timestamp: ~N[2018-02-19 16:51:23]}},
      {:temp_basal,
       %{
         rate: 3.05,
         rate_type: :absolute,
         raw: <<51, 122, 23, 179, 16, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 16:51:23]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 8, 169, 16, 83, 18>>, timestamp: ~N[2018-02-19 16:41:08]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 8, 169, 16, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 16:41:08]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 36, 162, 16, 83, 18>>, timestamp: ~N[2018-02-19 16:34:36]}},
      {:temp_basal,
       %{
         rate: 2.95,
         rate_type: :absolute,
         raw: <<51, 118, 36, 162, 16, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 16:34:36]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 36, 147, 16, 83, 18>>, timestamp: ~N[2018-02-19 16:19:36]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 36, 147, 16, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 16:19:36]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 21, 144, 16, 83, 18>>, timestamp: ~N[2018-02-19 16:16:21]}},
      {:temp_basal,
       %{
         rate: 2.45,
         rate_type: :absolute,
         raw: <<51, 98, 21, 144, 16, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 16:16:21]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 54, 137, 16, 83, 18>>, timestamp: ~N[2018-02-19 16:09:54]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 54, 137, 16, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 16:09:54]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 24, 131, 16, 83, 18>>, timestamp: ~N[2018-02-19 16:03:24]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 24, 131, 16, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 16:03:24]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 21, 181, 15, 83, 18>>, timestamp: ~N[2018-02-19 15:53:21]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 21, 181, 15, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 15:53:21]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 53, 172, 15, 83, 18>>, timestamp: ~N[2018-02-19 15:44:53]}},
      {:temp_basal,
       %{
         rate: 3.5,
         rate_type: :absolute,
         raw: <<51, 140, 53, 172, 15, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 15:44:53]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 46, 166, 15, 83, 18>>, timestamp: ~N[2018-02-19 15:38:46]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 46, 166, 15, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 15:38:46]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 17, 156, 15, 83, 18>>, timestamp: ~N[2018-02-19 15:28:17]}},
      {:temp_basal,
       %{
         rate: 3.2,
         rate_type: :absolute,
         raw: <<51, 128, 17, 156, 15, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 15:28:17]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 24, 155, 15, 83, 18>>, timestamp: ~N[2018-02-19 15:27:24]}},
      {:temp_basal,
       %{
         rate: 2.55,
         rate_type: :absolute,
         raw: <<51, 102, 24, 155, 15, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 15:27:24]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 44, 148, 15, 83, 18>>, timestamp: ~N[2018-02-19 15:20:44]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 44, 148, 15, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 15:20:44]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 33, 132, 15, 83, 18>>, timestamp: ~N[2018-02-19 15:04:33]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 33, 132, 15, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 15:04:33]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 11, 181, 14, 83, 18>>, timestamp: ~N[2018-02-19 14:53:11]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 11, 181, 14, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 14:53:11]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 16, 172, 14, 83, 18>>, timestamp: ~N[2018-02-19 14:44:16]}},
      {:temp_basal,
       %{
         rate: 2.2,
         rate_type: :absolute,
         raw: <<51, 88, 16, 172, 14, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 14:44:16]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 34, 170, 14, 83, 18>>, timestamp: ~N[2018-02-19 14:42:34]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 34, 170, 14, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 14:42:34]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 31, 154, 14, 83, 18>>, timestamp: ~N[2018-02-19 14:26:31]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 31, 154, 14, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 14:26:31]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 19, 145, 14, 83, 18>>, timestamp: ~N[2018-02-19 14:17:19]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 19, 145, 14, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 14:17:19]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 22, 133, 14, 83, 18>>, timestamp: ~N[2018-02-19 14:05:22]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 22, 133, 14, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 14:05:22]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 33, 176, 13, 83, 18>>, timestamp: ~N[2018-02-19 13:48:33]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 33, 176, 13, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 13:48:33]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 42, 172, 13, 83, 18>>, timestamp: ~N[2018-02-19 13:44:42]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 42, 172, 13, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 13:44:42]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 2, 158, 13, 83, 18>>, timestamp: ~N[2018-02-19 13:30:02]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 2, 158, 13, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 13:30:02]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 4, 145, 13, 83, 18>>, timestamp: ~N[2018-02-19 13:17:04]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 4, 145, 13, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 13:17:04]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 12, 187, 12, 83, 18>>, timestamp: ~N[2018-02-19 12:59:12]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 12, 187, 12, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 12:59:12]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 41, 170, 12, 83, 18>>, timestamp: ~N[2018-02-19 12:42:41]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 41, 170, 12, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 12:42:41]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 34, 168, 12, 83, 18>>, timestamp: ~N[2018-02-19 12:40:34]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 34, 168, 12, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 12:40:34]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 56, 165, 12, 83, 18>>, timestamp: ~N[2018-02-19 12:37:56]}},
      {:temp_basal,
       %{
         rate: 1.65,
         rate_type: :absolute,
         raw: <<51, 66, 56, 165, 12, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 12:37:56]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 18, 161, 12, 83, 18>>, timestamp: ~N[2018-02-19 12:33:18]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 18, 161, 12, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 12:33:18]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 7, 142, 12, 83, 18>>, timestamp: ~N[2018-02-19 12:14:07]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 7, 142, 12, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 12:14:07]
       }},
      {:bolus_normal,
       %{
         amount: 10.0,
         duration: 0,
         programmed: 10.0,
         raw: <<1, 100, 100, 0, 28, 134, 76, 19, 18>>,
         timestamp: ~N[2018-02-19 12:06:28],
         type: :normal
       }},
      {:bolus_wizard_estimate,
       %{
         bg: 0,
         bg_target_high: 110,
         bg_target_low: 90,
         bolus_estimate: 10.0,
         carb_ratio: 5,
         carbohydrates: 50,
         correction_estimate: 0.0,
         food_estimate: 10.0,
         insulin_sensitivity: 25,
         raw: <<91, 0, 28, 134, 12, 19, 18, 50, 80, 5, 25, 90, 0, 100, 0, 0, 0, 0, 100, 110>>,
         timestamp: ~N[2018-02-19 12:06:28],
         unabsorbed_insulin_total: 0.0
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 19, 128, 12, 83, 18>>, timestamp: ~N[2018-02-19 12:00:19]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 19, 128, 12, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 12:00:19]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 48, 174, 11, 83, 18>>, timestamp: ~N[2018-02-19 11:46:48]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 48, 174, 11, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 11:46:48]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 36, 169, 11, 83, 18>>, timestamp: ~N[2018-02-19 11:41:36]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 36, 169, 11, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 11:41:36]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 40, 152, 11, 83, 18>>, timestamp: ~N[2018-02-19 11:24:40]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 40, 152, 11, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 11:24:40]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 39, 136, 11, 83, 18>>, timestamp: ~N[2018-02-19 11:08:39]}},
      {:temp_basal,
       %{
         rate: 0.85,
         rate_type: :absolute,
         raw: <<51, 34, 39, 136, 11, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 11:08:39]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 57, 185, 10, 83, 18>>, timestamp: ~N[2018-02-19 10:57:57]}},
      {:temp_basal,
       %{
         rate: 0.9,
         rate_type: :absolute,
         raw: <<51, 36, 57, 185, 10, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 10:57:57]
       }},
      {:bolus_normal,
       %{
         amount: 16.0,
         duration: 0,
         programmed: 16.0,
         raw: <<1, 160, 160, 0, 45, 173, 74, 19, 18>>,
         timestamp: ~N[2018-02-19 10:45:45],
         type: :normal
       }},
      {:bolus_wizard_estimate,
       %{
         bg: 0,
         bg_target_high: 110,
         bg_target_low: 90,
         bolus_estimate: 16.0,
         carb_ratio: 5,
         carbohydrates: 80,
         correction_estimate: 0.0,
         food_estimate: 16.0,
         insulin_sensitivity: 25,
         raw: <<91, 0, 45, 173, 10, 19, 18, 80, 80, 5, 25, 90, 0, 160, 0, 0, 0, 0, 160, 110>>,
         timestamp: ~N[2018-02-19 10:45:45],
         unabsorbed_insulin_total: 0.0
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 44, 172, 10, 83, 18>>, timestamp: ~N[2018-02-19 10:44:44]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 44, 172, 10, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 10:44:44]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 22, 161, 10, 83, 18>>, timestamp: ~N[2018-02-19 10:33:22]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 22, 161, 10, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 10:33:22]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 23, 149, 10, 83, 18>>, timestamp: ~N[2018-02-19 10:21:23]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 23, 149, 10, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 10:21:23]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 6, 130, 10, 83, 18>>, timestamp: ~N[2018-02-19 10:02:06]}},
      {:temp_basal,
       %{
         rate: 0.95,
         rate_type: :absolute,
         raw: <<51, 38, 6, 130, 10, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 10:02:06]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 0, 176, 9, 83, 18>>, timestamp: ~N[2018-02-19 09:48:00]}},
      {:temp_basal,
       %{
         rate: 1.25,
         rate_type: :absolute,
         raw: <<51, 50, 0, 176, 9, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 09:48:00]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 20, 174, 9, 83, 18>>, timestamp: ~N[2018-02-19 09:46:20]}},
      {:temp_basal,
       %{
         rate: 3.45,
         rate_type: :absolute,
         raw: <<51, 138, 20, 174, 9, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 09:46:20]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 11, 162, 9, 83, 18>>, timestamp: ~N[2018-02-19 09:34:11]}},
      {:temp_basal,
       %{
         rate: 3.0,
         rate_type: :absolute,
         raw: <<51, 120, 11, 162, 9, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 09:34:11]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 3, 145, 9, 83, 18>>, timestamp: ~N[2018-02-19 09:17:03]}},
      {:temp_basal,
       %{
         rate: 2.8,
         rate_type: :absolute,
         raw: <<51, 112, 3, 145, 9, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 09:17:03]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 15, 132, 9, 83, 18>>, timestamp: ~N[2018-02-19 09:04:15]}},
      {:temp_basal,
       %{
         rate: 2.5,
         rate_type: :absolute,
         raw: <<51, 100, 15, 132, 9, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 09:04:15]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 2, 183, 8, 83, 18>>, timestamp: ~N[2018-02-19 08:55:02]}},
      {:temp_basal,
       %{
         rate: 1.25,
         rate_type: :absolute,
         raw: <<51, 50, 2, 183, 8, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 08:55:02]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 38, 161, 8, 83, 18>>, timestamp: ~N[2018-02-19 08:33:38]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 38, 161, 8, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 08:33:38]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 44, 156, 8, 83, 18>>, timestamp: ~N[2018-02-19 08:28:44]}},
      {:temp_basal,
       %{
         rate: 1.25,
         rate_type: :absolute,
         raw: <<51, 50, 44, 156, 8, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 08:28:44]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 28, 134, 8, 83, 18>>, timestamp: ~N[2018-02-19 08:06:28]}},
      {:temp_basal,
       %{
         rate: 1.25,
         rate_type: :absolute,
         raw: <<51, 50, 28, 134, 8, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 08:06:28]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 31, 181, 7, 83, 18>>, timestamp: ~N[2018-02-19 07:53:31]}},
      {:temp_basal,
       %{
         rate: 2.1,
         rate_type: :absolute,
         raw: <<51, 84, 31, 181, 7, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 07:53:31]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 31, 170, 7, 83, 18>>, timestamp: ~N[2018-02-19 07:42:31]}},
      {:temp_basal,
       %{
         rate: 1.95,
         rate_type: :absolute,
         raw: <<51, 78, 31, 170, 7, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 07:42:31]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 20, 152, 7, 83, 18>>, timestamp: ~N[2018-02-19 07:24:20]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 20, 152, 7, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 07:24:20]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 26, 149, 7, 83, 18>>, timestamp: ~N[2018-02-19 07:21:26]}},
      {:temp_basal,
       %{
         rate: 1.8,
         rate_type: :absolute,
         raw: <<51, 72, 26, 149, 7, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 07:21:26]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 28, 144, 7, 83, 18>>, timestamp: ~N[2018-02-19 07:16:28]}},
      {:temp_basal,
       %{
         rate: 1.05,
         rate_type: :absolute,
         raw: <<51, 42, 28, 144, 7, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 07:16:28]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 35, 138, 7, 83, 18>>, timestamp: ~N[2018-02-19 07:10:35]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 35, 138, 7, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 07:10:35]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 18, 176, 6, 83, 18>>, timestamp: ~N[2018-02-19 06:48:18]}},
      {:temp_basal,
       %{
         rate: 1.15,
         rate_type: :absolute,
         raw: <<51, 46, 18, 176, 6, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 06:48:18]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 43, 160, 6, 83, 18>>, timestamp: ~N[2018-02-19 06:32:43]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 43, 160, 6, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 06:32:43]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 24, 150, 6, 83, 18>>, timestamp: ~N[2018-02-19 06:22:24]}},
      {:temp_basal,
       %{
         rate: 1.15,
         rate_type: :absolute,
         raw: <<51, 46, 24, 150, 6, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 06:22:24]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 29, 130, 6, 83, 18>>, timestamp: ~N[2018-02-19 06:02:29]}},
      {:temp_basal,
       %{
         rate: 1.15,
         rate_type: :absolute,
         raw: <<51, 46, 29, 130, 6, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 06:02:29]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 23, 181, 5, 83, 18>>, timestamp: ~N[2018-02-19 05:53:23]}},
      {:temp_basal,
       %{
         rate: 2.35,
         rate_type: :absolute,
         raw: <<51, 94, 23, 181, 5, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 05:53:23]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 27, 166, 5, 83, 18>>, timestamp: ~N[2018-02-19 05:38:27]}},
      {:temp_basal,
       %{
         rate: 1.45,
         rate_type: :absolute,
         raw: <<51, 58, 27, 166, 5, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 05:38:27]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 28, 162, 5, 83, 18>>, timestamp: ~N[2018-02-19 05:34:28]}},
      {:temp_basal,
       %{
         rate: 2.25,
         rate_type: :absolute,
         raw: <<51, 90, 28, 162, 5, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 05:34:28]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 21, 160, 5, 83, 18>>, timestamp: ~N[2018-02-19 05:32:21]}},
      {:temp_basal,
       %{
         rate: 1.45,
         rate_type: :absolute,
         raw: <<51, 58, 21, 160, 5, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 05:32:21]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 48, 155, 5, 83, 18>>, timestamp: ~N[2018-02-19 05:27:48]}},
      {:temp_basal,
       %{
         rate: 2.15,
         rate_type: :absolute,
         raw: <<51, 86, 48, 155, 5, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 05:27:48]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 47, 149, 5, 83, 18>>, timestamp: ~N[2018-02-19 05:21:47]}},
      {:temp_basal,
       %{
         rate: 1.4,
         rate_type: :absolute,
         raw: <<51, 56, 47, 149, 5, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 05:21:47]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 15, 133, 5, 83, 18>>, timestamp: ~N[2018-02-19 05:05:15]}},
      {:temp_basal,
       %{
         rate: 1.4,
         rate_type: :absolute,
         raw: <<51, 56, 15, 133, 5, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 05:05:15]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 5, 180, 4, 83, 18>>, timestamp: ~N[2018-02-19 04:52:05]}},
      {:temp_basal,
       %{
         rate: 1.45,
         rate_type: :absolute,
         raw: <<51, 58, 5, 180, 4, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 04:52:05]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 56, 156, 4, 83, 18>>, timestamp: ~N[2018-02-19 04:28:56]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 56, 156, 4, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 04:28:56]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 40, 148, 4, 83, 18>>, timestamp: ~N[2018-02-19 04:20:40]}},
      {:temp_basal,
       %{
         rate: 1.45,
         rate_type: :absolute,
         raw: <<51, 58, 40, 148, 4, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 04:20:40]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 13, 128, 4, 83, 18>>, timestamp: ~N[2018-02-19 04:00:13]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 13, 128, 4, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 04:00:13]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 49, 178, 3, 83, 18>>, timestamp: ~N[2018-02-19 03:50:49]}},
      {:temp_basal,
       %{
         rate: 1.45,
         rate_type: :absolute,
         raw: <<51, 58, 49, 178, 3, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 03:50:49]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 9, 162, 3, 83, 18>>, timestamp: ~N[2018-02-19 03:34:09]}},
      {:temp_basal,
       %{
         rate: 1.45,
         rate_type: :absolute,
         raw: <<51, 58, 9, 162, 3, 83, 18, 0>>,
         timestamp: ~N[2018-02-19 03:34:09]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 14, 143, 3, 84, 18>>, timestamp: ~N[2018-02-19 03:15:14]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 14, 143, 3, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 03:15:14]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 58, 138, 3, 84, 18>>, timestamp: ~N[2018-02-19 03:10:58]}},
      {:temp_basal,
       %{
         rate: 1.25,
         rate_type: :absolute,
         raw: <<51, 50, 58, 138, 3, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 03:10:58]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 46, 132, 3, 84, 18>>, timestamp: ~N[2018-02-19 03:04:46]}},
      {:temp_basal,
       %{
         rate: 2.3,
         rate_type: :absolute,
         raw: <<51, 92, 46, 132, 3, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 03:04:46]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 54, 185, 2, 84, 18>>, timestamp: ~N[2018-02-19 02:57:54]}},
      {:temp_basal,
       %{
         rate: 1.15,
         rate_type: :absolute,
         raw: <<51, 46, 54, 185, 2, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 02:57:54]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 19, 168, 2, 84, 18>>, timestamp: ~N[2018-02-19 02:40:19]}},
      {:temp_basal,
       %{
         rate: 3.25,
         rate_type: :absolute,
         raw: <<51, 130, 19, 168, 2, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 02:40:19]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 32, 166, 2, 84, 18>>, timestamp: ~N[2018-02-19 02:38:32]}},
      {:temp_basal,
       %{
         rate: 2.55,
         rate_type: :absolute,
         raw: <<51, 102, 32, 166, 2, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 02:38:32]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 57, 161, 2, 84, 18>>, timestamp: ~N[2018-02-19 02:33:57]}},
      {:temp_basal,
       %{
         rate: 1.15,
         rate_type: :absolute,
         raw: <<51, 46, 57, 161, 2, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 02:33:57]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 27, 150, 2, 84, 18>>, timestamp: ~N[2018-02-19 02:22:27]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 27, 150, 2, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 02:22:27]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 36, 139, 2, 84, 18>>, timestamp: ~N[2018-02-19 02:11:36]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 36, 139, 2, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 02:11:36]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 57, 128, 2, 84, 18>>, timestamp: ~N[2018-02-19 02:00:57]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 57, 128, 2, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 02:00:57]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 4, 178, 1, 84, 18>>, timestamp: ~N[2018-02-19 01:50:04]}},
      {:temp_basal,
       %{
         rate: 1.1,
         rate_type: :absolute,
         raw: <<51, 44, 4, 178, 1, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 01:50:04]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 7, 158, 1, 84, 18>>, timestamp: ~N[2018-02-19 01:30:07]}},
      {:temp_basal,
       %{
         rate: 3.5,
         rate_type: :absolute,
         raw: <<51, 140, 7, 158, 1, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 01:30:07]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 14, 130, 1, 84, 18>>, timestamp: ~N[2018-02-19 01:02:14]}},
      {:temp_basal,
       %{
         rate: 3.5,
         rate_type: :absolute,
         raw: <<51, 140, 14, 130, 1, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 01:02:14]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 28, 183, 0, 84, 18>>, timestamp: ~N[2018-02-19 00:55:28]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 28, 183, 0, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 00:55:28]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 28, 172, 0, 84, 18>>, timestamp: ~N[2018-02-19 00:44:28]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 28, 172, 0, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 00:44:28]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 55, 159, 0, 84, 18>>, timestamp: ~N[2018-02-19 00:31:55]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 55, 159, 0, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 00:31:55]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 45, 147, 0, 84, 18>>, timestamp: ~N[2018-02-19 00:19:45]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 45, 147, 0, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 00:19:45]
       }},
      {:temp_basal_duration,
       %{duration: 30, raw: <<22, 1, 29, 136, 0, 84, 18>>, timestamp: ~N[2018-02-19 00:08:29]}},
      {:temp_basal,
       %{
         rate: 0.0,
         rate_type: :absolute,
         raw: <<51, 0, 29, 136, 0, 84, 18, 0>>,
         timestamp: ~N[2018-02-19 00:08:29]
       }},
      {:daily_total_522,
       %{
         raw:
           <<109, 51, 18, 5, 21, 24, 24, 24, 1, 0, 0, 11, 26, 4, 154, 41, 6, 128, 59, 0, 200, 6,
             128, 59, 5, 224, 90, 0, 160, 10, 0, 0, 0, 4, 3, 1, 0, 0, 12, 0, 232, 0, 0, 0>>,
         timestamp: ~N[2018-02-19 00:00:00]
       }},
      {:result_daily_total,
       %{
         raw: <<7, 0, 0, 11, 26, 51, 18>>,
         strokes: 2842,
         timestamp: ~N[2018-02-19 00:00:00],
         units: 71.05
       }}
    ]
  end

  defp sgv_entries do
    [
      {:sensor_glucose_value, %{sgv: 87, timestamp: ~N[2018-02-19 23:55:39.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 23:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 23:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 118, timestamp: ~N[2018-02-19 23:40:39.000]}},
      {:sensor_glucose_value, %{sgv: 127, timestamp: ~N[2018-02-19 23:35:39.000]}},
      {:sensor_glucose_value, %{sgv: 137, timestamp: ~N[2018-02-19 23:30:39.000]}},
      {:sensor_glucose_value, %{sgv: 145, timestamp: ~N[2018-02-19 23:25:39.000]}},
      {:sensor_glucose_value, %{sgv: 158, timestamp: ~N[2018-02-19 23:20:39.000]}},
      {:sensor_glucose_value, %{sgv: 166, timestamp: ~N[2018-02-19 23:15:39.000]}},
      {:sensor_glucose_value, %{sgv: 176, timestamp: ~N[2018-02-19 23:10:39.000]}},
      {:sensor_glucose_value, %{sgv: 183, timestamp: ~N[2018-02-19 23:05:39.000]}},
      {:sensor_glucose_value, %{sgv: 187, timestamp: ~N[2018-02-19 23:00:39.000]}},
      {:sensor_glucose_value, %{sgv: 195, timestamp: ~N[2018-02-19 22:55:39.000]}},
      {:sensor_glucose_value, %{sgv: 203, timestamp: ~N[2018-02-19 22:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 210, timestamp: ~N[2018-02-19 22:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 219, timestamp: ~N[2018-02-19 22:40:39.000]}},
      {:sensor_glucose_value, %{sgv: 228, timestamp: ~N[2018-02-19 22:35:39.000]}},
      {:sensor_glucose_value, %{sgv: 240, timestamp: ~N[2018-02-19 22:30:39.000]}},
      {:sensor_glucose_value, %{sgv: 247, timestamp: ~N[2018-02-19 22:25:39.000]}},
      {:sensor_glucose_value, %{sgv: 256, timestamp: ~N[2018-02-19 22:20:39.000]}},
      {:sensor_glucose_value, %{sgv: 267, timestamp: ~N[2018-02-19 22:15:39.000]}},
      {:sensor_glucose_value, %{sgv: 279, timestamp: ~N[2018-02-19 22:10:39.000]}},
      {:sensor_glucose_value, %{sgv: 289, timestamp: ~N[2018-02-19 22:05:39.000]}},
      {:sensor_glucose_value, %{sgv: 300, timestamp: ~N[2018-02-19 22:00:39.000]}},
      {:sensor_glucose_value, %{sgv: 308, timestamp: ~N[2018-02-19 21:55:39.000]}},
      {:sensor_glucose_value, %{sgv: 310, timestamp: ~N[2018-02-19 21:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 308, timestamp: ~N[2018-02-19 21:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 297, timestamp: ~N[2018-02-19 21:40:39.000]}},
      {:sensor_glucose_value, %{sgv: 285, timestamp: ~N[2018-02-19 21:35:39.000]}},
      {:sensor_glucose_value, %{sgv: 272, timestamp: ~N[2018-02-19 21:30:39.000]}},
      {:sensor_glucose_value, %{sgv: 263, timestamp: ~N[2018-02-19 21:25:44.000]}},
      {:sensor_glucose_value, %{sgv: 226, timestamp: ~N[2018-02-19 21:20:39.000]}},
      {:sensor_glucose_value, %{sgv: 216, timestamp: ~N[2018-02-19 21:15:39.000]}},
      {:sensor_glucose_value, %{sgv: 212, timestamp: ~N[2018-02-19 21:10:39.000]}},
      {:sensor_glucose_value, %{sgv: 208, timestamp: ~N[2018-02-19 21:05:39.000]}},
      {:sensor_glucose_value, %{sgv: 199, timestamp: ~N[2018-02-19 21:00:39.000]}},
      {:sensor_glucose_value, %{sgv: 191, timestamp: ~N[2018-02-19 20:55:39.000]}},
      {:sensor_glucose_value, %{sgv: 187, timestamp: ~N[2018-02-19 20:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 182, timestamp: ~N[2018-02-19 20:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 170, timestamp: ~N[2018-02-19 20:40:39.000]}},
      {:sensor_glucose_value, %{sgv: 169, timestamp: ~N[2018-02-19 20:35:39.000]}},
      {:sensor_glucose_value, %{sgv: 165, timestamp: ~N[2018-02-19 20:30:38.000]}},
      {:sensor_glucose_value, %{sgv: 154, timestamp: ~N[2018-02-19 20:25:39.000]}},
      {:sensor_glucose_value, %{sgv: 144, timestamp: ~N[2018-02-19 20:20:39.000]}},
      {:sensor_glucose_value, %{sgv: 138, timestamp: ~N[2018-02-19 20:15:39.000]}},
      {:sensor_glucose_value, %{sgv: 138, timestamp: ~N[2018-02-19 20:10:40.000]}},
      {:sensor_glucose_value, %{sgv: 139, timestamp: ~N[2018-02-19 20:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 139, timestamp: ~N[2018-02-19 20:00:39.000]}},
      {:sensor_glucose_value, %{sgv: 141, timestamp: ~N[2018-02-19 19:55:40.000]}},
      {:sensor_glucose_value, %{sgv: 141, timestamp: ~N[2018-02-19 19:50:40.000]}},
      {:sensor_glucose_value, %{sgv: 141, timestamp: ~N[2018-02-19 19:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 139, timestamp: ~N[2018-02-19 19:40:40.000]}},
      {:sensor_glucose_value, %{sgv: 137, timestamp: ~N[2018-02-19 19:30:40.000]}},
      {:sensor_glucose_value, %{sgv: 141, timestamp: ~N[2018-02-19 19:20:39.000]}},
      {:sensor_glucose_value, %{sgv: 141, timestamp: ~N[2018-02-19 19:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 141, timestamp: ~N[2018-02-19 19:10:39.000]}},
      {:sensor_glucose_value, %{sgv: 141, timestamp: ~N[2018-02-19 19:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 138, timestamp: ~N[2018-02-19 19:00:40.000]}},
      {:sensor_glucose_value, %{sgv: 135, timestamp: ~N[2018-02-19 18:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 137, timestamp: ~N[2018-02-19 18:45:40.000]}},
      {:sensor_glucose_value, %{sgv: 140, timestamp: ~N[2018-02-19 18:40:40.000]}},
      {:sensor_glucose_value, %{sgv: 144, timestamp: ~N[2018-02-19 18:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 151, timestamp: ~N[2018-02-19 18:30:39.000]}},
      {:sensor_glucose_value, %{sgv: 161, timestamp: ~N[2018-02-19 18:25:40.000]}},
      {:sensor_glucose_value, %{sgv: 173, timestamp: ~N[2018-02-19 18:20:40.000]}},
      {:sensor_glucose_value, %{sgv: 166, timestamp: ~N[2018-02-19 18:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 156, timestamp: ~N[2018-02-19 18:10:40.000]}},
      {:sensor_glucose_value, %{sgv: 157, timestamp: ~N[2018-02-19 18:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 155, timestamp: ~N[2018-02-19 18:00:40.000]}},
      {:sensor_glucose_value, %{sgv: 154, timestamp: ~N[2018-02-19 17:55:39.000]}},
      {:sensor_glucose_value, %{sgv: 156, timestamp: ~N[2018-02-19 17:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 153, timestamp: ~N[2018-02-19 17:45:40.000]}},
      {:sensor_glucose_value, %{sgv: 151, timestamp: ~N[2018-02-19 17:40:39.000]}},
      {:sensor_glucose_value, %{sgv: 150, timestamp: ~N[2018-02-19 17:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 148, timestamp: ~N[2018-02-19 17:30:40.000]}},
      {:sensor_glucose_value, %{sgv: 148, timestamp: ~N[2018-02-19 17:25:40.000]}},
      {:sensor_glucose_value, %{sgv: 143, timestamp: ~N[2018-02-19 17:20:40.000]}},
      {:sensor_glucose_value, %{sgv: 146, timestamp: ~N[2018-02-19 17:15:39.000]}},
      {:sensor_glucose_value, %{sgv: 149, timestamp: ~N[2018-02-19 17:10:39.000]}},
      {:sensor_glucose_value, %{sgv: 149, timestamp: ~N[2018-02-19 17:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 149, timestamp: ~N[2018-02-19 17:00:39.000]}},
      {:sensor_glucose_value, %{sgv: 150, timestamp: ~N[2018-02-19 16:55:40.000]}},
      {:sensor_glucose_value, %{sgv: 151, timestamp: ~N[2018-02-19 16:50:40.000]}},
      {:sensor_glucose_value, %{sgv: 149, timestamp: ~N[2018-02-19 16:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 149, timestamp: ~N[2018-02-19 16:40:40.000]}},
      {:sensor_glucose_value, %{sgv: 150, timestamp: ~N[2018-02-19 16:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 151, timestamp: ~N[2018-02-19 16:30:39.000]}},
      {:sensor_glucose_value, %{sgv: 149, timestamp: ~N[2018-02-19 16:25:40.000]}},
      {:sensor_glucose_value, %{sgv: 145, timestamp: ~N[2018-02-19 16:20:40.000]}},
      {:sensor_glucose_value, %{sgv: 145, timestamp: ~N[2018-02-19 16:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 146, timestamp: ~N[2018-02-19 16:10:40.000]}},
      {:sensor_glucose_value, %{sgv: 144, timestamp: ~N[2018-02-19 16:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 143, timestamp: ~N[2018-02-19 16:00:39.000]}},
      {:sensor_glucose_value, %{sgv: 145, timestamp: ~N[2018-02-19 15:55:39.000]}},
      {:sensor_glucose_value, %{sgv: 145, timestamp: ~N[2018-02-19 15:50:40.000]}},
      {:sensor_glucose_value, %{sgv: 146, timestamp: ~N[2018-02-19 15:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 142, timestamp: ~N[2018-02-19 15:40:40.000]}},
      {:sensor_glucose_value, %{sgv: 132, timestamp: ~N[2018-02-19 15:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 131, timestamp: ~N[2018-02-19 15:30:40.000]}},
      {:sensor_glucose_value, %{sgv: 126, timestamp: ~N[2018-02-19 15:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 120, timestamp: ~N[2018-02-19 15:20:40.000]}},
      {:sensor_glucose_value, %{sgv: 114, timestamp: ~N[2018-02-19 15:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 108, timestamp: ~N[2018-02-19 15:10:40.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 15:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 15:00:41.000]}},
      {:sensor_glucose_value, %{sgv: 96, timestamp: ~N[2018-02-19 14:55:41.000]}},
      {:sensor_glucose_value, %{sgv: 98, timestamp: ~N[2018-02-19 14:50:40.000]}},
      {:sensor_glucose_value, %{sgv: 96, timestamp: ~N[2018-02-19 14:45:41.000]}},
      {:sensor_glucose_value, %{sgv: 87, timestamp: ~N[2018-02-19 14:40:40.000]}},
      {:sensor_glucose_value, %{sgv: 78, timestamp: ~N[2018-02-19 14:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 73, timestamp: ~N[2018-02-19 14:30:40.000]}},
      {:sensor_glucose_value, %{sgv: 72, timestamp: ~N[2018-02-19 14:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 69, timestamp: ~N[2018-02-19 14:20:40.000]}},
      {:sensor_glucose_value, %{sgv: 64, timestamp: ~N[2018-02-19 14:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 62, timestamp: ~N[2018-02-19 14:10:41.000]}},
      {:sensor_glucose_value, %{sgv: 62, timestamp: ~N[2018-02-19 14:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 64, timestamp: ~N[2018-02-19 14:00:40.000]}},
      {:sensor_glucose_value, %{sgv: 62, timestamp: ~N[2018-02-19 13:55:40.000]}},
      {:sensor_glucose_value, %{sgv: 61, timestamp: ~N[2018-02-19 13:50:41.000]}},
      {:sensor_glucose_value, %{sgv: 60, timestamp: ~N[2018-02-19 13:45:40.000]}},
      {:sensor_glucose_value, %{sgv: 59, timestamp: ~N[2018-02-19 13:40:41.000]}},
      {:sensor_glucose_value, %{sgv: 60, timestamp: ~N[2018-02-19 13:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 63, timestamp: ~N[2018-02-19 13:30:40.000]}},
      {:sensor_glucose_value, %{sgv: 67, timestamp: ~N[2018-02-19 13:25:40.000]}},
      {:sensor_glucose_value, %{sgv: 67, timestamp: ~N[2018-02-19 13:20:40.000]}},
      {:sensor_glucose_value, %{sgv: 70, timestamp: ~N[2018-02-19 13:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 74, timestamp: ~N[2018-02-19 13:10:41.000]}},
      {:sensor_glucose_value, %{sgv: 80, timestamp: ~N[2018-02-19 13:05:41.000]}},
      {:sensor_glucose_value, %{sgv: 87, timestamp: ~N[2018-02-19 13:00:40.000]}},
      {:sensor_glucose_value, %{sgv: 93, timestamp: ~N[2018-02-19 12:55:41.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 12:50:41.000]}},
      {:sensor_glucose_value, %{sgv: 96, timestamp: ~N[2018-02-19 12:45:41.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 12:40:40.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 12:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 101, timestamp: ~N[2018-02-19 12:30:41.000]}},
      {:sensor_glucose_value, %{sgv: 99, timestamp: ~N[2018-02-19 12:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 101, timestamp: ~N[2018-02-19 12:20:41.000]}},
      {:sensor_glucose_value, %{sgv: 103, timestamp: ~N[2018-02-19 12:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 12:10:40.000]}},
      {:sensor_glucose_value, %{sgv: 98, timestamp: ~N[2018-02-19 12:05:40.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 12:00:40.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 11:55:41.000]}},
      {:sensor_glucose_value, %{sgv: 111, timestamp: ~N[2018-02-19 11:50:40.000]}},
      {:sensor_glucose_value, %{sgv: 117, timestamp: ~N[2018-02-19 11:45:41.000]}},
      {:sensor_glucose_value, %{sgv: 123, timestamp: ~N[2018-02-19 11:40:41.000]}},
      {:sensor_glucose_value, %{sgv: 126, timestamp: ~N[2018-02-19 11:35:40.000]}},
      {:sensor_glucose_value, %{sgv: 128, timestamp: ~N[2018-02-19 11:30:41.000]}},
      {:sensor_glucose_value, %{sgv: 129, timestamp: ~N[2018-02-19 11:25:40.000]}},
      {:sensor_glucose_value, %{sgv: 124, timestamp: ~N[2018-02-19 11:20:40.000]}},
      {:sensor_glucose_value, %{sgv: 116, timestamp: ~N[2018-02-19 11:15:40.000]}},
      {:sensor_glucose_value, %{sgv: 108, timestamp: ~N[2018-02-19 11:10:40.000]}},
      {:sensor_glucose_value, %{sgv: 106, timestamp: ~N[2018-02-19 11:05:41.000]}},
      {:sensor_glucose_value, %{sgv: 105, timestamp: ~N[2018-02-19 11:00:41.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 10:55:42.000]}},
      {:sensor_glucose_value, %{sgv: 102, timestamp: ~N[2018-02-19 10:50:41.000]}},
      {:sensor_glucose_value, %{sgv: 98, timestamp: ~N[2018-02-19 10:45:42.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 10:40:42.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 10:35:41.000]}},
      {:sensor_glucose_value, %{sgv: 107, timestamp: ~N[2018-02-19 10:30:41.000]}},
      {:sensor_glucose_value, %{sgv: 109, timestamp: ~N[2018-02-19 10:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 111, timestamp: ~N[2018-02-19 10:20:41.000]}},
      {:sensor_glucose_value, %{sgv: 114, timestamp: ~N[2018-02-19 10:15:41.000]}},
      {:sensor_glucose_value, %{sgv: 117, timestamp: ~N[2018-02-19 10:10:41.000]}},
      {:sensor_glucose_value, %{sgv: 118, timestamp: ~N[2018-02-19 10:05:41.000]}},
      {:sensor_glucose_value, %{sgv: 119, timestamp: ~N[2018-02-19 10:00:41.000]}},
      {:sensor_glucose_value, %{sgv: 120, timestamp: ~N[2018-02-19 09:55:41.000]}},
      {:sensor_glucose_value, %{sgv: 120, timestamp: ~N[2018-02-19 09:50:42.000]}},
      {:sensor_glucose_value, %{sgv: 119, timestamp: ~N[2018-02-19 09:45:41.000]}},
      {:sensor_glucose_value, %{sgv: 122, timestamp: ~N[2018-02-19 09:40:41.000]}},
      {:sensor_glucose_value, %{sgv: 119, timestamp: ~N[2018-02-19 09:35:41.000]}},
      {:sensor_glucose_value, %{sgv: 114, timestamp: ~N[2018-02-19 09:30:41.000]}},
      {:sensor_glucose_value, %{sgv: 112, timestamp: ~N[2018-02-19 09:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 111, timestamp: ~N[2018-02-19 09:20:41.000]}},
      {:sensor_glucose_value, %{sgv: 107, timestamp: ~N[2018-02-19 09:15:42.000]}},
      {:sensor_glucose_value, %{sgv: 106, timestamp: ~N[2018-02-19 09:10:41.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 09:05:42.000]}},
      {:sensor_glucose_value, %{sgv: 103, timestamp: ~N[2018-02-19 09:00:41.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 08:55:42.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 08:50:41.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 08:45:41.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 08:40:42.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 08:35:41.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 08:30:41.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 08:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 106, timestamp: ~N[2018-02-19 08:20:41.000]}},
      {:sensor_glucose_value, %{sgv: 107, timestamp: ~N[2018-02-19 08:15:42.000]}},
      {:sensor_glucose_value, %{sgv: 107, timestamp: ~N[2018-02-19 08:10:41.000]}},
      {:sensor_glucose_value, %{sgv: 107, timestamp: ~N[2018-02-19 08:05:41.000]}},
      {:sensor_glucose_value, %{sgv: 107, timestamp: ~N[2018-02-19 08:00:41.000]}},
      {:sensor_glucose_value, %{sgv: 107, timestamp: ~N[2018-02-19 07:55:41.000]}},
      {:sensor_glucose_value, %{sgv: 106, timestamp: ~N[2018-02-19 07:50:41.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 07:45:41.000]}},
      {:sensor_glucose_value, %{sgv: 102, timestamp: ~N[2018-02-19 07:40:41.000]}},
      {:sensor_glucose_value, %{sgv: 99, timestamp: ~N[2018-02-19 07:35:42.000]}},
      {:sensor_glucose_value, %{sgv: 99, timestamp: ~N[2018-02-19 07:30:41.000]}},
      {:sensor_glucose_value, %{sgv: 98, timestamp: ~N[2018-02-19 07:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 99, timestamp: ~N[2018-02-19 07:20:41.000]}},
      {:sensor_glucose_value, %{sgv: 101, timestamp: ~N[2018-02-19 07:15:41.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 07:10:41.000]}},
      {:sensor_glucose_value, %{sgv: 94, timestamp: ~N[2018-02-19 07:05:41.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 07:00:42.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 06:55:41.000]}},
      {:sensor_glucose_value, %{sgv: 98, timestamp: ~N[2018-02-19 06:50:41.000]}},
      {:sensor_glucose_value, %{sgv: 98, timestamp: ~N[2018-02-19 06:45:41.000]}},
      {:sensor_glucose_value, %{sgv: 96, timestamp: ~N[2018-02-19 06:40:41.000]}},
      {:sensor_glucose_value, %{sgv: 92, timestamp: ~N[2018-02-19 06:35:41.000]}},
      {:sensor_glucose_value, %{sgv: 92, timestamp: ~N[2018-02-19 06:30:41.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 06:25:41.000]}},
      {:sensor_glucose_value, %{sgv: 99, timestamp: ~N[2018-02-19 06:20:41.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 06:15:42.000]}},
      {:sensor_glucose_value, %{sgv: 100, timestamp: ~N[2018-02-19 06:10:42.000]}},
      {:sensor_glucose_value, %{sgv: 99, timestamp: ~N[2018-02-19 06:05:42.000]}},
      {:sensor_glucose_value, %{sgv: 99, timestamp: ~N[2018-02-19 06:00:42.000]}},
      {:sensor_glucose_value, %{sgv: 98, timestamp: ~N[2018-02-19 05:55:42.000]}},
      {:sensor_glucose_value, %{sgv: 96, timestamp: ~N[2018-02-19 05:50:42.000]}},
      {:sensor_glucose_value, %{sgv: 92, timestamp: ~N[2018-02-19 05:45:42.000]}},
      {:sensor_glucose_value, %{sgv: 90, timestamp: ~N[2018-02-19 05:40:41.000]}},
      {:sensor_glucose_value, %{sgv: 90, timestamp: ~N[2018-02-19 05:35:42.000]}},
      {:sensor_glucose_value, %{sgv: 92, timestamp: ~N[2018-02-19 05:30:42.000]}},
      {:sensor_glucose_value, %{sgv: 90, timestamp: ~N[2018-02-19 05:25:42.000]}},
      {:sensor_glucose_value, %{sgv: 88, timestamp: ~N[2018-02-19 05:20:42.000]}},
      {:sensor_glucose_value, %{sgv: 88, timestamp: ~N[2018-02-19 05:15:42.000]}},
      {:sensor_glucose_value, %{sgv: 86, timestamp: ~N[2018-02-19 05:10:42.000]}},
      {:sensor_glucose_value, %{sgv: 85, timestamp: ~N[2018-02-19 05:05:42.000]}},
      {:sensor_glucose_value, %{sgv: 85, timestamp: ~N[2018-02-19 05:00:42.000]}},
      {:sensor_glucose_value, %{sgv: 84, timestamp: ~N[2018-02-19 04:55:42.000]}},
      {:sensor_glucose_value, %{sgv: 85, timestamp: ~N[2018-02-19 04:50:42.000]}},
      {:sensor_glucose_value, %{sgv: 85, timestamp: ~N[2018-02-19 04:45:42.000]}},
      {:sensor_glucose_value, %{sgv: 86, timestamp: ~N[2018-02-19 04:40:42.000]}},
      {:sensor_glucose_value, %{sgv: 87, timestamp: ~N[2018-02-19 04:35:42.000]}},
      {:sensor_glucose_value, %{sgv: 88, timestamp: ~N[2018-02-19 04:30:42.000]}},
      {:sensor_glucose_value, %{sgv: 89, timestamp: ~N[2018-02-19 04:25:42.000]}},
      {:sensor_glucose_value, %{sgv: 92, timestamp: ~N[2018-02-19 04:20:42.000]}},
      {:sensor_glucose_value, %{sgv: 93, timestamp: ~N[2018-02-19 04:15:42.000]}},
      {:sensor_glucose_value, %{sgv: 94, timestamp: ~N[2018-02-19 04:10:42.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 04:05:42.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 04:00:42.000]}},
      {:sensor_glucose_value, %{sgv: 94, timestamp: ~N[2018-02-19 03:55:42.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 03:50:42.000]}},
      {:sensor_glucose_value, %{sgv: 95, timestamp: ~N[2018-02-19 03:45:42.000]}},
      {:sensor_glucose_value, %{sgv: 96, timestamp: ~N[2018-02-19 03:40:41.000]}},
      {:sensor_glucose_value, %{sgv: 96, timestamp: ~N[2018-02-19 03:35:42.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 03:30:42.000]}},
      {:sensor_glucose_value, %{sgv: 97, timestamp: ~N[2018-02-19 03:25:42.000]}},
      {:sensor_glucose_value, %{sgv: 120, timestamp: ~N[2018-02-19 03:20:38.000]}},
      {:sensor_glucose_value, %{sgv: 123, timestamp: ~N[2018-02-19 03:15:38.000]}},
      {:sensor_glucose_value, %{sgv: 126, timestamp: ~N[2018-02-19 03:10:38.000]}},
      {:sensor_glucose_value, %{sgv: 130, timestamp: ~N[2018-02-19 03:05:38.000]}},
      {:sensor_glucose_value, %{sgv: 133, timestamp: ~N[2018-02-19 03:00:39.000]}},
      {:sensor_glucose_value, %{sgv: 130, timestamp: ~N[2018-02-19 02:55:38.000]}},
      {:sensor_glucose_value, %{sgv: 133, timestamp: ~N[2018-02-19 02:50:38.000]}},
      {:sensor_glucose_value, %{sgv: 134, timestamp: ~N[2018-02-19 02:45:38.000]}},
      {:sensor_glucose_value, %{sgv: 134, timestamp: ~N[2018-02-19 02:40:38.000]}},
      {:sensor_glucose_value, %{sgv: 131, timestamp: ~N[2018-02-19 02:35:38.000]}},
      {:sensor_glucose_value, %{sgv: 127, timestamp: ~N[2018-02-19 02:30:38.000]}},
      {:sensor_glucose_value, %{sgv: 123, timestamp: ~N[2018-02-19 02:25:38.000]}},
      {:sensor_glucose_value, %{sgv: 120, timestamp: ~N[2018-02-19 02:20:38.000]}},
      {:sensor_glucose_value, %{sgv: 120, timestamp: ~N[2018-02-19 02:15:38.000]}},
      {:sensor_glucose_value, %{sgv: 120, timestamp: ~N[2018-02-19 02:10:38.000]}},
      {:sensor_glucose_value, %{sgv: 124, timestamp: ~N[2018-02-19 02:05:38.000]}},
      {:sensor_glucose_value, %{sgv: 127, timestamp: ~N[2018-02-19 02:00:38.000]}},
      {:sensor_glucose_value, %{sgv: 130, timestamp: ~N[2018-02-19 01:55:38.000]}},
      {:sensor_glucose_value, %{sgv: 133, timestamp: ~N[2018-02-19 01:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 133, timestamp: ~N[2018-02-19 01:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 135, timestamp: ~N[2018-02-19 01:40:39.000]}},
      {:sensor_glucose_value, %{sgv: 134, timestamp: ~N[2018-02-19 01:35:38.000]}},
      {:sensor_glucose_value, %{sgv: 132, timestamp: ~N[2018-02-19 01:30:38.000]}},
      {:sensor_glucose_value, %{sgv: 127, timestamp: ~N[2018-02-19 01:25:39.000]}},
      {:sensor_glucose_value, %{sgv: 118, timestamp: ~N[2018-02-19 01:20:38.000]}},
      {:sensor_glucose_value, %{sgv: 113, timestamp: ~N[2018-02-19 01:15:38.000]}},
      {:sensor_glucose_value, %{sgv: 111, timestamp: ~N[2018-02-19 01:10:39.000]}},
      {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2018-02-19 01:05:38.000]}},
      {:sensor_glucose_value, %{sgv: 91, timestamp: ~N[2018-02-19 01:00:38.000]}},
      {:sensor_glucose_value, %{sgv: 73, timestamp: ~N[2018-02-19 00:55:39.000]}},
      {:sensor_glucose_value, %{sgv: 56, timestamp: ~N[2018-02-19 00:50:39.000]}},
      {:sensor_glucose_value, %{sgv: 45, timestamp: ~N[2018-02-19 00:45:39.000]}},
      {:sensor_glucose_value, %{sgv: 47, timestamp: ~N[2018-02-19 00:40:39.000]}},
      {:sensor_glucose_value, %{sgv: 49, timestamp: ~N[2018-02-19 00:35:39.000]}},
      {:sensor_glucose_value, %{sgv: 51, timestamp: ~N[2018-02-19 00:30:39.000]}},
      {:sensor_glucose_value, %{sgv: 54, timestamp: ~N[2018-02-19 00:25:39.000]}},
      {:sensor_glucose_value, %{sgv: 57, timestamp: ~N[2018-02-19 00:20:39.000]}},
      {:sensor_glucose_value, %{sgv: 60, timestamp: ~N[2018-02-19 00:15:39.000]}},
      {:sensor_glucose_value, %{sgv: 64, timestamp: ~N[2018-02-19 00:10:39.000]}},
      {:sensor_glucose_value, %{sgv: 69, timestamp: ~N[2018-02-19 00:05:39.000]}},
      {:sensor_glucose_value, %{sgv: 78, timestamp: ~N[2018-02-19 00:00:39.000]}}
    ]
  end
end
