defmodule Pummpcomm.Session.Exchange.ReadSettings do
  @moduledoc """
  Reads settings about max basal, max bolus, selected basal profile (for basal profile patterns) and the insulin action
  curve in hours.
  """

  alias Pummpcomm.Insulin
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @basal_multiplier 40.0
  @bolus_multiplier 10.0
  @opcode 0xC0

  # Types

  @typedoc """
  The basal profile

  * `:standard` - when basal profile patterns are not enabled
  * `:profile_a` - the A profile when basal profile patterns are enabled
  * `:profile_b` - the B profile when basal profile patterns are enabled
  """
  @type basal_profile :: :profile_a | :profile_b | :standard

  # Functions

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to the max basal, max bolus, selected basal profile
  (for basal profile patterns) and the insulin action curve in hours from pump with `pump_serial`
  """
  @spec decode(Response.t) :: {
                                :ok,
                                %{
                                  insulin_action_curve_hours: non_neg_integer,
                                  max_basal: Insulin.units,
                                  max_bolus: Insulin.units,
                                  selected_basal_profile: basal_profile
                                }
                              }
  def decode(%Response{opcode: @opcode,
                       data: <<_::8, _::40, max_bolus_ticks::8, max_basal_ticks::16, _::16,
                       raw_basal_profile::8, _::40, insulin_action_curve_hours::8, _::binary>>}) do

    {:ok, %{max_bolus: max_bolus_ticks / @bolus_multiplier,
            max_basal: max_basal_ticks / @basal_multiplier,
            selected_basal_profile: selected_basal_profile(raw_basal_profile),
            insulin_action_curve_hours: insulin_action_curve_hours}
    }
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read the max basal, max bolus, selected basal profile
  (for basal profile patterns) and the insulin action curve in hours from pump with `pump_serial`
  """
  @spec make(Command.pump_serial) :: Command.t
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  ## Private Functions

  defp selected_basal_profile(1), do: :profile_a
  defp selected_basal_profile(2), do: :profile_b
  defp selected_basal_profile(_), do: :standard
end
