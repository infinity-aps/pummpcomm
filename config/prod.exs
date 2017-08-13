use Mix.Config

config :logger, level: :debug
config :pummpcomm, :serial_driver, Pummpcomm.Driver.SubgRfspy.UART
config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, :cgm, Pummpcomm.Session.Pump
