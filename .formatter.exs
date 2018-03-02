[
  inputs: ["mix.exs"] ++ Path.wildcard("{config,lib,test}/**/*.{ex,exs}") -- ["lib/pummpcomm/cgm.ex", "lib/pummpcomm/crc/crc16.ex", "lib/pummpcomm/crc/crc8.ex", "lib/pummpcomm/history.ex"]
]
