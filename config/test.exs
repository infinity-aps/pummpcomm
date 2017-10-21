use Mix.Config

config :logger, level: :warn

config :pummpcomm, :pump_driver, SubgRfspy
config :pummpcomm, :pump, Pummpcomm.Session.PumpFake
config :pummpcomm, :cgm, Pummpcomm.Session.PumpFake

config :subg_rfspy, :serial_driver, SubgRfspy.UARTProxy
