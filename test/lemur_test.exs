defmodule LemurTest do
  use ExUnit.Case
  doctest Lemur

  test "run two nodes, post on each then connect and see both replicate" do
    [node1, node2] =
      LocalCluster.start_nodes(:spawn, 2,
        # add iex to remotely run code on other nodes
        files: [
          __ENV__.file
        ],
        applications: [:lemur],
        environment: [
          lemur: &build_env/1
        ]
      )

    # simple posts on spawned instances
    journal(node1, "bar2", "tzobien0")
    journal(node2, "bar3", "tzobien1")

    # connect from node1 to node2 to replicate
    Node.spawn(node1, fn ->
      Baby.connect("localhost", 8484, identity: "tzobien0", clump_id: "Quagga")
    end)

    # sleep some to let replication do it's thing
    Process.sleep(5000)

    # check that spawned node has replicate data
    assert(length(stored_info(node1)) == 2)
    assert(length(stored_info(node2)) == 2)

    :ok = LocalCluster.stop_nodes([node1, node2])

    :ok = LocalCluster.stop()

    assert Node.ping(node1) == :pang
    assert Node.ping(node2) == :pang
  end

  defp build_env(n) do
    cfg =
      [
        spool_dir: "~/.lemur-test/node" <> Integer.to_string(n) <> "/baobab",
        clumps: [
          [
            id: "Quagga",
            controlling_identity: "tzobien" <> Integer.to_string(n),
            port: 8483 + n,
            cryouts: []
          ]
        ]
      ]

    cfg
  end

  defp journal(node, post, author) do
    Node.spawn(node, fn ->
      Baobab.append_log(post, author, log_id: 360_360, clump_id: "Quagga")
    end)
  end

  defp stored_info(node) do
    caller = self()

    Node.spawn(node, fn ->
      send(caller, Baobab.stored_info("Quagga"))
    end)

    receive do
      any ->
        IO.puts("Stored info from " <> Atom.to_string(node))
        IO.inspect(any)
        any
    end
  end
end
