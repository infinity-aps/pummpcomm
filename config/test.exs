use Mix.Config

config :logger, level: :debug
config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.Fake
config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
