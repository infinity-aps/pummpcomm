defmodule Pummpcomm.Session.Exchange.ReadSettings do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0xC0
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  # @newer_format_length 25
  @bolus_multiplier 10.0
  @basal_multiplier 40.0
  # def decode(%Response{opcode: @opcode,
  #                      data: <<@newer_format_length::8, _::48, max_bolus_ticks::8, max_basal_ticks::16, _::16,
  #                      raw_basal_profile::8, _::48, insulin_action_curve_hours::8, _::binary>>}) do

  #   %{max_bolus: max_bolus_ticks * @bolus_multiplier,
  #     max_basal: max_basal_ticks * @basal_multiplier,
  #     selected_basal_profile: selected_basal_profile(raw_basal_profile),
  #     insulin_action_curve_hours: insulin_action_curve_hours
  #   }
  # end

  def decode(%Response{opcode: @opcode,
                       data: <<_::8, _::40, max_bolus_ticks::8, max_basal_ticks::16, _::16,
                       raw_basal_profile::8, _::40, insulin_action_curve_hours::8, _::binary>>}) do

    %{max_bolus: max_bolus_ticks / @bolus_multiplier,
      max_basal: max_basal_ticks / @basal_multiplier,
      selected_basal_profile: selected_basal_profile(raw_basal_profile),
      insulin_action_curve_hours: insulin_action_curve_hours
    }
  end

  def selected_basal_profile(1), do: :profile_a
  def selected_basal_profile(2), do: :profile_b
  def selected_basal_profile(_), do: :standard
end
