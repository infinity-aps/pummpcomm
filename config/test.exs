use Mix.Config

config :logger, level: :warn
config :subg_rfspy, :serial_driver, SubgRfspy.UARTProxy
config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
config :pummpcomm, :cgm, Pummpcomm.Session.PumpFake
