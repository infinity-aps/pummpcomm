defmodule Pummpcomm.Monitor.BloodGlucoseMonitor do
  require Logger

  @pump Application.get_env(:pummpcomm, :pump)

  def get_sensor_values(minutes_back) do
    oldest_allowed = oldest_entry_allowed(minutes_back)
    Logger.debug "Searching until we find an entry older than #{inspect(oldest_allowed)}"

    %{page_number: page_number} = @pump.get_current_cgm_page
    {:ok, fetch_and_filter_page(page_number, [], oldest_allowed, page_number - 5)}
  end

  defp fetch_and_filter_page(-1, sensor_values, _, _), do: Enum.reverse(sensor_values)
  defp fetch_and_filter_page(page_number, sensor_values, oldest_allowed, lowest_page_allowed) when page_number < lowest_page_allowed do
    Logger.warn "Reached max page fetches before finding an entry older than #{inspect(oldest_allowed)}"
    Enum.reverse(sensor_values)
  end

  defp fetch_and_filter_page(page_number, sensor_values, oldest_allowed, lowest_page_allowed) do
    {:ok, values} = @pump.read_cgm_page(page_number)
    newest_first_values = Enum.reverse(values)
    {oldest_reached, sensor_values} = Enum.filter_map(newest_first_values, &filter_glucose_value/1, &process_cgm_entry/1) |> filter_by_date(sensor_values, oldest_allowed)
    case oldest_reached do
      true -> Enum.reverse(sensor_values)
      false -> fetch_and_filter_page(page_number - 1, sensor_values, oldest_allowed, lowest_page_allowed)
    end
  end

  defp filter_by_date([], allowed_entries, _), do: {false, allowed_entries}
  defp filter_by_date([head | tail], allowed_entries, oldest_allowed) do
    case Timex.before?(head.timestamp, oldest_allowed) do
      true -> {true, allowed_entries}
      false -> filter_by_date(tail, [head | allowed_entries], oldest_allowed)
    end
  end

  defp filter_glucose_value({:sensor_glucose_value, _}), do: true
  defp filter_glucose_value(_),                          do: false

  defp process_cgm_entry({:sensor_glucose_value, glucose_entry}) do
    entry = %{sgv: glucose_entry.sgv, timestamp: glucose_entry.timestamp}
    Logger.debug "Looking at #{inspect(entry)}"
    entry
  end

  defp oldest_entry_allowed(minutes_back) do
    Timex.local |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive
  end
end
