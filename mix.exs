defmodule Lemur.MixProject do
  use Mix.Project

  def project do
    [
      app: :lemur,
      version: "0.1.0",
      elixir: "~> 1.14",
      description: description(),
      start_permanent: Mix.env() == :prod,
      aliases: [
        test: "test --no-start"
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Lemur.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # use local path for hacking
      ## {:baby, path: "/Users/cmoid/code/baby_ex"},
      {:baby, git: "https://github.com/cmoid/baby_ex"},
      ## {:local_cluster, "~> 1.2", only: [:test]},
      {:local_cluster, git: "https://github.com/cmoid/local-cluster"},
      ## local_cluster needs some hacks to be useful
      ## {:local_cluster, path: "/Users/cmoid/code/local-cluster"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Lemur is for testing bushbaby and baobab
    """
  end
end
