defmodule Timestamper do

  def timestamp_relative_events([]), do: []
  def timestamp_relative_events(events) do
    events
    |> Enum.reverse
    |> process_events([], [])
  end

  defp process_events([], processed, _), do: processed
  defp process_events([event | tail], processed, needs_timestamp) do
    cond do
      is_relative_event?(event)  -> process_events(tail, processed, [event | needs_timestamp])
      is_reference_event?(event) -> process_events(tail, add_timestamps(event, needs_timestamp, processed), [])
      true                       -> process_events(tail, [event | processed], needs_timestamp)
    end
  end

  defp add_timestamps(reference_event, relative_events, processed) do
    timestamp = event_timestamp(reference_event)

    processed = relative_events
    |> Enum.with_index
    |> Enum.map(fn({relative_event, index}) ->
      timestamp
      |> Timex.shift(minutes: 5 * (index + 1))
      |> add_timestamp(relative_event)
    end)
    |> Enum.concat(processed)

    [reference_event | processed]
  end

  defp add_timestamp(timestamp, event) do
    {event_key(event), Map.put(event_map(event), :timestamp, timestamp)}
  end

  defp event_key(event), do: elem(event, 0)

  defp event_map(event) when tuple_size(event) == 1, do: %{}
  defp event_map(event) when tuple_size(event) >= 2, do: elem(event, 1)

  defp event_timestamp(event), do: event_map(event)[:timestamp]

  @reference_events [:sensor_timestamp, :ten_something, :sensor_calibration_factor]
  defp is_reference_event?(event), do: event_key(event) in @reference_events

  @relative_events [:data_end, :sensor_weak_signal, :sensor_calibration, :nineteen_something, :sensor_glucose_value]
  defp is_relative_event?(event), do:  event_key(event) in @relative_events
end
