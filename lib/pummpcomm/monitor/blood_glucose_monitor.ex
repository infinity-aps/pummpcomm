defmodule Pummpcomm.Monitor.BloodGlucoseMonitor do
  @moduledoc """
  This module provides high-level continuous glucose monitor functions, such as the ability to retrieve a specific
  number of historical minutes of cgm data. It manages the process of pulling the right number of cgm pages from the
  insulin pump, along with handling Medtronic cgm-specific details like writing reference timestamps for accurate cgm
  decoding.
  """

  require Logger
  alias Pummpcomm.Cgm
  alias Pummpcomm.Cgm.Timestamper
  alias Pummpcomm.Monitor.BloodGlucoseMonitor

  @enforce_keys [:cgm]
  defstruct [:cgm]

  def get_sensor_values(%BloodGlucoseMonitor{cgm: cgm}, minutes_back, timezone) do
    oldest_allowed = oldest_entry_allowed(minutes_back, timezone)

    Logger.info(fn ->
      "Searching until we find a cgm entry older than #{inspect(oldest_allowed)}"
    end)

    {:ok, %{page_number: page_number}} = cgm.get_current_cgm_page()
    {:ok, fetch_and_filter_page(cgm, page_number, [], oldest_allowed, page_number - 5)}
  end

  defp fetch_and_filter_page(_, -1, sensor_values, _, _), do: Enum.reverse(sensor_values)

  defp fetch_and_filter_page(_, page_number, sensor_values, oldest_allowed, lowest_page_allowed)
       when page_number < lowest_page_allowed do
    Logger.warn(fn ->
      "Reached max page fetches before finding an entry older than #{inspect(oldest_allowed)}"
    end)

    Enum.reverse(sensor_values)
  end

  defp fetch_and_filter_page(cgm, page_number, sensor_values, oldest_allowed, lowest_page_allowed) do
    {:ok, values} = cgm.read_cgm_page(page_number)

    case Cgm.needs_timestamp?(values) do
      true ->
        Logger.info(fn -> "Writing cgm timestamp on page #{page_number}" end)
        :ok = cgm.write_cgm_timestamp()

        fetch_and_filter_page(
          cgm,
          page_number,
          sensor_values,
          oldest_allowed,
          lowest_page_allowed
        )

      false ->
        newest_first_values = Enum.reverse(values)

        {oldest_reached, sensor_values} =
          newest_first_values
          |> Enum.filter(&filter_glucose_value/1)
          |> filter_by_date(sensor_values, oldest_allowed)

        case oldest_reached do
          true ->
            Enum.reverse(sensor_values)

          false ->
            fetch_and_filter_page(
              cgm,
              page_number - 1,
              sensor_values,
              oldest_allowed,
              lowest_page_allowed
            )
        end
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

  defp filter_glucose_value({event_key, _}) do
    event_key in Timestamper.relative_events()
  end

  defp oldest_entry_allowed(minutes_back, timezone) do
    timezone |> Timex.now() |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive()
  end
end
