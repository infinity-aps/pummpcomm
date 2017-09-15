defmodule Pummpcomm.TempBasal do
  @moduledoc """
  Temporary Basal
  """

  alias Pummpcomm.Insulin

  @typedoc """
  Percentage from `0` to `200`.
  """
  @type percent :: 0..200

  @typedoc """
  The rate of the temporary basal: either `:absolute` `Pummpcomm.Insulin.units_per_hour` or a `:percent` `percent` of
  the normal bolus `Pummpcomm.Insulin.units_per_hour`.
  """
  @type rate :: Insulin.units_per_hour | percent

  @typedoc """
  Whether the temporary basal can be entered as an `:absolute` number of units per hour OR a `:percentage` of the normal
  basal.
  """
  @type type :: :absolute | :percent
end
