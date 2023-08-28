import Config

config :logger, level: :info

# Be sure that all defined ports are properly mapped in the
# Dockerfile.
config :lemur,
  spool_dir: "~/.lemur-test/node/baobab",
  clumps: [
    [
      id: "Quagga",
      controlling_identity: "xiaoli",
      ## controlling_secret: System.get_env("QUAGGA_SECRET_KEY"),
      port: 8482,
      cryouts: [],
      ## [host: "moid2.fly.dev", port: 8483, period: {2, :hour}]],
      public: %{
        "name" => "basque",
        "host" => "localhost",
        "nicker_log_id" => 8482
      }
    ]
  ]
