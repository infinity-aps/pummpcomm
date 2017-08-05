defmodule Pummpcomm.Monitor.HistoryMonitor do
  require Logger

  @pump Application.get_env(:pummpcomm, :pump)

  def get_pump_history(minutes_back) do
    oldest_allowed = oldest_entry_allowed(minutes_back)
    Logger.debug "Searching until we find an entry older than #{inspect(oldest_allowed)}"

    {:ok, fetch_and_filter_page(0, [], oldest_allowed, 5)}
  end

  defp fetch_and_filter_page(page_number, history_events, oldest_allowed, highest_page_allowed) when page_number > highest_page_allowed do
    Logger.warn "Reached max page fetches before finding an event older than #{inspect(oldest_allowed)}"
    Enum.reverse(history_events)
  end

  defp fetch_and_filter_page(page_number, history_events, oldest_allowed, highest_page_allowed) do
    {:ok, values} = @pump.read_history_page(page_number)
    newest_first_values = Enum.reverse(values)
    {oldest_reached, history_events} = Enum.filter(newest_first_values, &filter_history_event/1) |> filter_by_date(history_events, oldest_allowed)
    case oldest_reached do
      true -> Enum.reverse(history_events)
      false -> fetch_and_filter_page(page_number + 1, history_events, oldest_allowed, highest_page_allowed)
    end
  end

  defp filter_by_date([], allowed_entries, _), do: {false, allowed_entries}
  defp filter_by_date([head | tail], allowed_entries, oldest_allowed) do
    {_, event_data} = head
    case Timex.before?(event_data.timestamp, oldest_allowed) do
      true -> {true, allowed_entries}
      false -> filter_by_date(tail, [head | allowed_entries], oldest_allowed)
    end
  end

  defp filter_history_event({_, %{timestamp: _}}), do: true
  defp filter_history_event({_, _}), do: false

  defp oldest_entry_allowed(minutes_back) do
    Timex.local |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive
  end
end
