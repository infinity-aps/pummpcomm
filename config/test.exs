use Mix.Config

config :logger, level: :warn
config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.Fake
config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
