defmodule Pummpcomm.History.MealMarkerTest do
  use ExUnit.Case

  test "Meal Marker" do
    {:ok, history_page} = Base.decode16("40006D6D171D0F2C01")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:meal_marker, %{ carbohydrates: 44, carb_units: :grams, timestamp: ~N[2015-05-29 23:45:45], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
