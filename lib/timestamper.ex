defmodule Timestamper do

  def timestamp_relative_events([]), do: []
  def timestamp_relative_events(events) do
    events
    |> Enum.reverse
    |> process_events([], [])
  end

  defp process_events([], in_transition, processed), do: in_transition ++ processed
  defp process_events([event | tail], in_transition, processed) do
    cond do
      is_reference_event?(event) -> process_events(tail, [], add_timestamps(event, in_transition, processed))
      true                       -> process_events(tail, [event | in_transition], processed)
    end
  end

  defp add_timestamps(reference_event, to_be_processed, processed) do
    timestamp = event_timestamp(reference_event)
    {events_with_timestamps, thing} = Enum.map_reduce(to_be_processed, timestamp, fn(event, timestamp) ->
      cond do
        is_relative_event?(event)  ->
          timestamp = Timex.shift(timestamp, minutes: 5)
          event = add_timestamp(event, timestamp)
          {event, timestamp}
        true -> {event, timestamp}
      end
    end)
    [reference_event | Enum.concat(events_with_timestamps, processed)]
  end

  defp add_timestamp(event, timestamp) do
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
