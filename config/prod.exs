use Mix.Config

config :logger, level: :debug
config :pummpcomm, Pummpcomm.Driver.SubgRfspy,
  serial_driver: Pummpcomm.Driver.SubgRfspy.UART
