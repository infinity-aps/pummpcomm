use Mix.Config

config :logger, level: :debug
config :subg_rfspy, :serial_driver, SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, :cgm, Pummpcomm.Session.Pump
