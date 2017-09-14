defmodule Pummpcomm.Insulin do
  @moduledoc """
  Insulin
  """

  # Types

  @typedoc """
  The number of `Pummpcomm.BloodGlucose.blood_glucose` per `Pummpcomm.Insulin.units`
  """
  @type blood_glucose_per_unit :: non_neg_integer

  @typedoc """
  The number of `Pummpcomm.Carbohydrates.carbohydrates` of food per `Pummpcomm.Insulin.units`
  """
  @type carbohydrates_per_unit :: non_neg_integer

  @typedoc """
  Units of U100 (100 units per 1mL) insulin
  """
  @type units :: float

  @typedoc """
  `units` per hour
  """
  @type units_per_hour :: float
end
