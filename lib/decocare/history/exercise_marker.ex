defmodule Decocare.History.ExerciseMarker do
  alias Decocare.DateDecoder

  def decode_exercise_marker(<<_::8, timestamp::binary-size(5), _::8>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
