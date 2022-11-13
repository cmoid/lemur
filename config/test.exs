import Config

config :lemur,
  spool_dir: "~/.lemur-test/node/baobab",
  clumps: [
    [
      id: "Quagga",
      controlling_identity: "xiaoli",
      port: 8482,
      public: %{
        "name" => "basque",
        "host" => "localhost",
        "nicker_log_id" => 8482
      }
    ]
  ]
