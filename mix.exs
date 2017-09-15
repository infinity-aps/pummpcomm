defmodule Pummpcomm.Mixfile do
  use Mix.Project

  def project do
    [aliases: aliases(),
     app: :pummpcomm,
     version: "2.3.0",
     elixir: ">= 1.4.5", elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     name: "Pummpcomm",
     source_url: "https://github.com/infinity-aps/pummpcomm",
     description: description(),
     package: package(),
     preferred_cli_env: [
       "dialyzer": :test
     ]]
  end

  def application do
    [extra_applications: extra_applications(Mix.env)]
  end

  ## Private Functions

  defp aliases do
    [
      "compile": "compile --warnings-as-errors"
    ]
  end

  defp deps do
    [{:timex, "~> 3.0"},
     {:subg_rfspy, github: "infinity-aps/elixir_subg_rfspy"},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.5.1", only: :test, runtime: false},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    """
    Pummpcomm is a library to handle communication with a Medtronic insulin pump via a serial link to a cc1110 chip running subg_rfspy.
    """
  end

  defp extra_applications(:test), do: [:ex_unit | extra_applications(:dev)]
  defp extra_applications(_), do: [:logger]

  defp package do
    [
      maintainers: ["Timothy Mecklem"],
      licenses: ["MIT License"],
      links: %{"Github" => "https://github.com/infinity-aps/pummpcomm"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
