use Mix.Config

config :logger, level: :debug
config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.Fake
  # base_frequency: Float.parse(System.get_env("SUBG_RFSPY_BASE_FREQUENCY")) |> elem(0)
