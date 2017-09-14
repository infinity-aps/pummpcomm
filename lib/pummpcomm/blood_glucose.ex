defmodule Pummpcomm.BloodGlucose do
  @moduledoc """
  The blood glucose of the pump user
  """

  # Types

  @typedoc """
  The blood glucose of the user in either mg/dL (US system) or mmol/L (International)
  """
  @type blood_glucose :: non_neg_integer
end
