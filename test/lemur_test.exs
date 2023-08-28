defmodule LemurTest do
  use ExUnit.Case
  doctest Lemur

  test "run two nodes, post on each then connect and see both replicate" do
    File.rm_rf("~/.lemur-test" |> Path.expand())
    [node1, node2] = spin_up_nodes(:test1, 2)

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

    assert Node.ping(node1) == :pang
    assert Node.ping(node2) == :pang
    Process.sleep(3000)
  end

  test "run three nodes and connect them n1 -> n2, with a simple post to each" do
    File.rm_rf("~/.lemur-test" |> Path.expand())
    [node1, node2, node3] = spin_up_nodes(:test2, 3)

    # simple posts on spawned instances
    journal(node1, "bar2", "tzobien0")
    journal(node2, "bar3", "tzobien1")
    journal(node3, "bar4", "tzobien2")

    # connect from node1 to node2 to replicate
    Node.spawn(node1, fn ->
      Baby.connect("localhost", 8484, identity: "tzobien0", clump_id: "Quagga")
    end)

    # connect from node2 to node3 to replicate
    Node.spawn(node2, fn ->
      Baby.connect("localhost", 8485, identity: "tzobien1", clump_id: "Quagga")
    end)

    # connect from node3 to node1 to replicate

    # sleep some to let replication do it's thing
    Process.sleep(7000)

    # check that spawned node has replicate data
    assert(length(stored_info(node1)) == 2)
    assert(length(stored_info(node2)) == 3)
    assert(length(stored_info(node3)) == 2)

    # now connect n3 -> n1, to see all nodes now fully replicated
    Node.spawn(node3, fn ->
      Baby.connect("localhost", 8483, identity: "tzobien2", clump_id: "Quagga")
    end)

    Process.sleep(7000)

    assert(length(stored_info(node1)) == 3)
    assert(length(stored_info(node2)) == 3)
    assert(length(stored_info(node3)) == 3)

    Enum.map([node1, node2, node3], fn n -> identities(n) end)

    :ok = LocalCluster.stop_nodes([node1, node2, node3])

    assert Node.ping(node1) == :pang
    assert Node.ping(node2) == :pang
    assert Node.ping(node3) == :pang

    Process.sleep(3000)
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

  defp identities(node) do
    caller = self()

    Node.spawn(node, fn ->
      send(caller, Baobab.Identity.list())
    end)

    receive do
      any ->
        IO.puts("Identities on " <> Atom.to_string(node))
        IO.inspect(any)
        any
    end
  end

  defp spin_up_nodes(name, n) do
    LocalCluster.start_nodes(name, n,
      # add iex to remotely run code on other nodes
      files: [
        __ENV__.file
      ],
      applications: [:lemur],
      environment: [
        lemur: &build_env/1
      ]
    )
  end
end
