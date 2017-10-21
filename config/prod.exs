use Mix.Config

config :logger, level: :debug

config :pummpcomm, :pump_driver, SubgRfspy
config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, :cgm, Pummpcomm.Session.Pump

config :subg_rfspy, :serial_driver, SubgRfspy.UART
