defmodule Pummpcomm.Command.ReadPumpModel do
  alias Pummpcomm.Crc8

  @doc """
  Format a command to read the pump's model number

  ## Examples

  iex> Pummpcomm.Command.ReadPumpModel.encode("665455")
  {:read_pump_model, <<0x01, 0x00, 0xA7, 0x01, 0x665455::size(24), 0x80, 0x00, 0x00, 0x02, 0x01, 0x00, 0x8D, 0x5B, 0x00>>, %{max_retries: 2}}
  iex> Pummpcomm.Command.ReadPumpModel.encode("659303")
  {:read_pump_model, <<0x01, 0x00, 0xA7, 0x01, 0x659303::size(24), 0x80, 0x00, 0x00, 0x02, 0x01, 0x00, 0x8D, 0xF3, 0x00>>, %{max_retries: 2}}
  """
  @carelink_packet_type 0xA7
  @args 0
  @retries 2
  @expected_pages 1
  @command_code 0x8D
  def encode(serial) do
    command_body = <<0x01, 0x00, @carelink_packet_type, 0x01>> <> encode_serial(serial) <>
                   <<0x80, @args::size(8), 0x00, @retries::size(8), @expected_pages::size(8), 0x00>> <>
                   <<@command_code::size(8)>>
    params = <<>>
    { command_type, assemble_command(command_body, params), %{max_retries: @retries} }
  end

  defp assemble_command(command_body, params) do
    command_body <> <<Crc8.crc_8(command_body)::size(8)>> <> params <> <<Crc8.crc_8(params)::size(8)>>
  end

  defp encode_serial(serial) do
    encoded = serial |> Integer.parse(16) |> elem(0)
    <<encoded::size(24)>>
  end

  defp command_type do
    __MODULE__ |> Module.split |> List.last |> Macro.underscore |> String.to_atom
  end
end
