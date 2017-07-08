defmodule Pummpcomm.Session.PumpFake do
  def get_current_cgm_page do
    %{glucose: 32, isig: 32, page_number: 10}
  end

  # returns 4 sensor glucose values starting at 3 minutes ago
  def read_cgm_page(10) do
    timestamp = [:sensor_timestamp, %{event_type: :page_end, raw: <<16, 40, 182, 20, 8>>, timestamp: ~N[2016-02-08 20:54:00]}]

    {:ok,
     [timestamp | Enum.map(0..3, fn(item) -> generate_sgv((item * 5) + 3) end)]
    }
  end

  def read_cgm_page(9) do
    {:ok,
     Enum.map(4..13, fn(item) -> generate_sgv((item * 5) + 3) end)
    }
  end

  defp generate_sgv(minutes_back) do
    date_time = Timex.local |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive
    [:sensor_glucose_value, %{sgv: 200 - minutes_back, timestamp: date_time}]
  end
end
