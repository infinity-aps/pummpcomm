defmodule Pummpcomm.Mixfile do
  use Mix.Project

  def project do
    [app: :pummpcomm,
     version: "1.2.0",
     elixir: "~> 1.4.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     name: "Pummpcomm",
     source_url: "https://github.com/tmecklem/pummpcomm",
     description: description(),
     package: package()]
  end

  def application do
    [applications: [:logger, :nerves_uart, :timex]]
  end

  defp deps do
    [{:nerves_uart, "~> 0.1.1"},
     {:timex, "~> 3.0"},
     {:csv, "~> 2.0.0"}]
  end

  defp description do
    """
    Pummpcomm is a library to handle communication with a Medtronic insulin pump via a serial link to a cc1110 chip running subg_rfspy.
    """
  end

  defp package do
    [
      maintainers: ["Timothy Mecklem"],
      licenses: ["MIT License"],
      links: %{"Github" => "https://github.com/tmecklem/pummpcomm"}
    ]
  end
end
