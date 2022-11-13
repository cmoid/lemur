# Lemur

Lemur is an application used primarily to test and exercise [baby][1], and [baobab][2] together. It makes use of a library, [local-cluster][3], that allows one to spin up several `BEAM` instances on the same machine and execute `rpc` calls between them.

This will help in testing baby and baobab together.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lemur` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lemur, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/lemur>.

----
[1]: https://github.com/mwmiller/baby_ex
[2]: https://github.com/mwmiller/baobab_ex
[3]: https://github.com/cmoid/local-cluster


