defmodule Pummpcomm.Carbohydrates do
  @moduledoc """
  Carbohydrates consumed in either grams or [exchanges](https://dtc.ucsf.edu/living-with-diabetes/diet-and-nutrition/understanding-carbohydrates/counting-carbohydrates/carbohydrate-exchanges/)
  """

  @typedoc """
  [exchanges](https://dtc.ucsf.edu/living-with-diabetes/diet-and-nutrition/understanding-carbohydrates/counting-carbohydrates/carbohydrate-exchanges/)
  of carbohydrates.  Normally 15 grams per exchange, but it depends on food type.  Raw value from pump is in 1/10th of
  an exchange, so it's not a float on the pump itself.
  """
  @type exchanges :: float

  @typedoc """
  Grams of carbohydrates
  """
  @type grams :: non_neg_integer

  @typedoc """
  Carbohydrates consumed in either grams or [exchanges](https://dtc.ucsf.edu/living-with-diabetes/diet-and-nutrition/understanding-carbohydrates/counting-carbohydrates/carbohydrate-exchanges/)
  """
  @type carbohydrates :: exchanges | grams

  @typedoc """
  The unit `carbohydrates` is in.
  """
  @type units :: :grams | :exchanges
end
