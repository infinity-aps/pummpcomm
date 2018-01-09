use Mix.Config

config :logger, level: :debug

config :pummpcomm, :pump, Pummpcomm.Session.Pump
config :pummpcomm, :cgm, Pummpcomm.Session.Pump
