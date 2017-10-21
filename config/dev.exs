use Mix.Config

config :logger, level: :debug

# Use SubgRfspy or RFM69 for packet radio
config :pummpcomm, :pump_driver, SubgRfspy

config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, :cgm, Pummpcomm.Session.Pump

# Use UART or SPI for serial transport of SubgRfspy
# (This is not needed if pump_driver is RFM69
config :subg_rfspy, :serial_driver, SubgRfspy.SPI
