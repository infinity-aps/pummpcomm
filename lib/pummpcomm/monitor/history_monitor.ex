defmodule Pummpcomm.Monitor.HistoryMonitor do
  @moduledoc """
  This module provides high-level access to the pump history information. It fetches history data to the specified
  minutes back, fetching multiple pages of history if necessary until the desired timeframe has been decoded.
  """
  require Logger

  def get_pump_history(minutes_back, timezone) do
    oldest_allowed = oldest_entry_allowed(minutes_back, timezone)
    Logger.info fn -> "Searching until we find a history entry older than #{inspect(oldest_allowed)}" end

    {:ok, fetch_and_filter_page(0, [], oldest_allowed, 5)}
  end

  defp fetch_and_filter_page(page_number, history_events, oldest_allowed, highest_page_allowed) when page_number > highest_page_allowed do
    Logger.warn fn -> "Reached max page fetches before finding an event older than #{inspect(oldest_allowed)}" end
    Enum.reverse(history_events)
  end

  defp fetch_and_filter_page(page_number, history_events, oldest_allowed, highest_page_allowed) do
    {:ok, values} = pump().read_history_page(page_number)
    newest_first_values = Enum.reverse(values)
    {oldest_reached, history_events} = newest_first_values
                                       |> Enum.filter(&filter_history_event/1)
                                       |> filter_by_date(history_events, oldest_allowed)
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

  defp oldest_entry_allowed(minutes_back, timezone) do
    timezone |> Timex.now() |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive
  end

  defp pump, do: Application.get_env(:pummpcomm, :pump)
end
