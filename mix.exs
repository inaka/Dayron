defmodule Dayron.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :dayron,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps,
      # Hex
      source_url: "https://github.com/inaka/Dayron",
      homepage_url: "https://github.com/inaka/Dayron",
      description: description,
      # Docs
      name: "Dayron",
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :crutches]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison,       "~> 2.0"},
      {:httpoison,    "~> 0.8.0"},
      {:crutches,     "~> 1.0.0"},
      {:credo,        "~> 0.3",     only: [:dev, :test]},
      {:bypass,       "~> 0.1",     only: :test},
      {:excoveralls,  "~> 0.5",     only: :test},
      {:inch_ex,      "~> 0.5",     only: :docs},
      {:earmark,      "~> 0.1",     only: :docs},
      {:ex_doc,       "~> 0.11",    only: :docs}
    ]
  end

  defp description do
    """
    Dayron is a flexible library to interact with resources from REST APIs and map them to models in Elixir.
    """
  end
end
