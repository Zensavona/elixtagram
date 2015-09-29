defmodule Elixtagram.Mixfile do
  use Mix.Project

  def project do
    [app: :elixtagram,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison, :oauth2]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.7.4"},
      {:poison, "~> 1.5"},
      {:oauth2, "~> 0.3"},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :docs},
      {:excoveralls, "~> 0.3", only: [:dev, :test]},
      {:inch_ex, "~> 0.4.0", only: [:dev, :docs]}
    ]
  end

  defp description do
    """
    Instagram client library for Elixir.
    """
  end

  defp package do
    [ contributors: ["zensavona"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/zensavona/elixtagram"} ]
  end
end
