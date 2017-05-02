defmodule Pummpcomm.Mixfile do
  use Mix.Project

  def project do
    [app: :pummpcomm,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :nerves_uart, :timex]]
  end

  defp deps do
    [{:nerves_uart, "~> 0.1.1"},
     {:timex, "~> 3.0"}]
  end
end
