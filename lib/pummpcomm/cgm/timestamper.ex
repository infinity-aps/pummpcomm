defmodule Pummpcomm.Cgm.Timestamper do
  @moduledoc """
  Adds timestamps to events based on the preceeding timestamps or timestamped events in a series of events
  """

  # Constants

  @relative_events [:sensor_weak_signal, :sensor_calibration, :sensor_glucose_value, :sensor_data_low,
                    :sensor_data_high, :sensor_error, :sensor_packet]

  # Types

  @typedoc """
  An event
  """
  @type event :: tuple

  @typedoc """
  The name of an `event`
  """
  @type event_name :: atom

  # Functions

  @doc """
  If the event can serve as a reference timestamp for relative events that precede it
  """
  @spec is_reference_event?(event) :: boolean
  def is_reference_event?(event), do: event_key(event) == :sensor_timestamp

  @doc """
  If the event's timestamp is relative to the reference event's timestamp
  """
  @spec is_relative_event?(event) :: boolean
  def is_relative_event?(event), do: event_key(event) in @relative_events

  @doc """
  All events that are relative to the previous timestamp in the event series
  """
  @spec relative_events() :: [event_name, ...]
  def relative_events, do: @relative_events

  @doc """
  Adds timestamps to all relative events in `events` using the reference events' timestamps
  """
  @spec timestamp_events([event]) :: [event]
  def timestamp_events(events) do
    reverse_events = Enum.reverse(events)
    process_events(reverse_events, [], try_find_timestamp(reverse_events, 0))
  end

  ## Private Functions

  defp process_events([], processed, _), do: processed

  defp process_events([event | tail], processed, timestamp) do
    cond do
      is_reference_event?(event) ->
        reference_timestamp = elem(event, 1)[:timestamp]
        process_events(tail, [event | processed], reference_timestamp)
      is_relative_event?(event)  ->
        event = add_timestamp(event, timestamp)
        timestamp = decrement_timestamp(timestamp)
        process_events(tail, [event | processed], timestamp)
      true                       ->
        process_events(tail, [event | processed], timestamp)
    end
  end

  defp decrement_timestamp(nil), do: nil
  defp decrement_timestamp(timestamp), do: Timex.shift(timestamp, minutes: -5)

  defp add_timestamp(event, timestamp) do
    {event_key(event), Map.put(event_map(event), :timestamp, timestamp)}
  end

  defp try_find_timestamp([], _), do: nil
  defp try_find_timestamp([event | tail], count) do
    cond do
      is_relative_event?(event) ->
        try_find_timestamp(tail, count + 1)
      event_key(event) in [:data_end, :nineteen_something, :null_byte] ->
        try_find_timestamp(tail, count)
      is_reference_event?(event) && event_map(event)[:event_type] == :last_rf ->
        timestamp = event_map(event)[:timestamp]
        Timex.shift(timestamp, minutes: count * 5)
      true ->
        nil
    end
  end

  defp event_key(event), do: elem(event, 0)

  defp event_map(event) when tuple_size(event) == 1, do: %{}
  defp event_map(event) when tuple_size(event) >= 2, do: elem(event, 1)
end
