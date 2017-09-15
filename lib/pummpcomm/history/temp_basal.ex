defmodule Pummpcomm.History.TempBasal do
  @moduledoc """
  When a temporary basal was started
  """

  use Bitwise

  alias Pummpcomm.{DateDecoder, Insulin, TempBasal}

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when temporary basal with `rate` of `rate_type` was started
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{
                                                              rate: TempBasal.rate,
                                                              rate_type: TempBasal.type,
                                                              timestamp: NaiveDateTime.t
                                                            }
  def decode(body, pump_options)
  def decode(<<rate_low_bits::8, timestamp::binary-size(5), raw_rate_type::5, rate_high_bits::3>>, _) do
    rate_type = rate_type(raw_rate_type)

    %{
      rate_type: rate_type,
      rate: rate(rate_type, rate_high_bits, rate_low_bits),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  ## Private Functions

  defp rate_type(0), do: :absolute
  defp rate_type(_), do: :percent

  @spec rate(:absolute, 0..7, 0..255) :: Insulin.units_per_hour
  defp rate(:absolute, rate_high_bits, rate_low_bits), do: ((rate_high_bits <<< 8) + rate_low_bits) / 40.0
  @spec rate(:percent, 0..7, 0..255) :: TempBasal.percent
  defp rate(:percent, _, rate_low_bits), do: rate_low_bits
end
