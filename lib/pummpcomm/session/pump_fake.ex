defmodule Pummpcomm.Session.PumpFake do
  def get_current_cgm_page do
    %{glucose: 32, isig: 32, page_number: 10}
  end

  # returns 4 sensor glucose values starting at 3 minutes ago
  def read_cgm_page(10) do
    {:ok,
     Enum.map(3..0, fn(item) -> generate_sgv((item * 5) + 3) end)
    }
  end

  def read_cgm_page(9) do
    timestamp = [:sensor_timestamp, %{event_type: :page_end, raw: <<16, 40, 182, 20, 8>>, timestamp: time_for_minutes_back(23)}]
    {
      :ok,
      Enum.map(13..4, fn(item) -> generate_sgv((item * 5) + 3) end) ++ [timestamp]
    }
  end

  defp generate_sgv(minutes_back) do
    {:sensor_glucose_value,
     %{sgv: 200 - minutes_back, timestamp: time_for_minutes_back(minutes_back)}}
  end

  defp time_for_minutes_back(minutes_back) do
    Timex.local |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive
  end
end
