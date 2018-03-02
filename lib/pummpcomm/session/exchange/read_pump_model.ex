defmodule Pummpcomm.Session.Exchange.ReadPumpModel do
  @moduledoc """
  Reads `Pumpcomm.PumpModel.pump_model` from pump
  """

  alias Pummpcomm.PumpModel
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x8D

  # Functions

  @doc """
  Decodes `Pummpcomm.PumpModel.pump_model` from `Pummpcomm.Session.Response.t` to `make/1`
  `Pumpcomm.Session.Command.t`
  """
  @spec decode(Response.t()) :: %{model_number: PumpModel.pump_model()}
  def decode(%Response{opcode: @opcode, data: <<length::8, rest::binary>>}) do
    {:ok, model_number} = PumpModel.model_number(binary_part(rest, 0, length))
    %{model_number: model_number}
  end

  @doc """
  Makes `Pummpcomm.PumpModel.Command.t` to read `Pummpcomm.PumpModel.pump_model` from pump with
  `Pumpcomm.Session.Command.pump_serial`
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
