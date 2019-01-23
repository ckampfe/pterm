footer: `persistent_term`
slidenumbers: true

## `persistent_term`

---

# Hello

- Clark Kampfe
- Fast Radius
- Additive Manufacturing (3D printing)
- Phoenix, Nerves in production
- Yes we're hiring


---

# Elixir/Erlang VM: The BEAM

- Error handling with restarts/supervision
- Concurrency story
- Process GC is independent
- Everything is copied (some exceptions)

---

# Problem

- Global data
- That is big
- With many concurrent readers

--------

# Solutions in context

- GenServer
- ETS
- FastGlobal
- persistent_term (new!)

---

# GenServer

```elixir
defmodule Pterm.MapServer do

  use GenServer

  # PUBLIC
  ######################################

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get(pid) do
    GenServer.call(pid, :get, 30_000)
  end

  # CALLBACKS
  ######################################

  def init(%{data: data} = _args) do
    {:ok, data}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end

### Client

{:ok, server} = Pterm.MapServer.start_link(%{data: %{a: 1, b: 2}})
Pterm.MapServer.get(server) #=> %{a: 1, b: 2}
```


---

# GenServer

- Like every other Erlang process
- Easy, not the fastest
- Idiomatic, battle-tested
- Built in
- Data is copied to caller: keyspace access patterns matter!
- Process mailbox can bottleneck reads and writes

---

# ETS - Erlang Term Storage

```elixir

hosts = %{...}

:ets.new(:hosts, [{:read_concurrency, true}, :named_table])

:ets.insert(:hosts, {:hosts_data, big_hosts_data})

[{:hosts_data, data}] = :ets.lookup(:hosts, :hosts_data)

```

---

# ETS - Erlang Term Storage

- Basically, Redis
- Big mutable hash table
- Easy, fast
- Built in
- Not GC'd
- Data is copied to caller: keyspace access patterns matter!

---

# FastGlobal

```elixir
hosts = %{...}

FastGlobal.put(:hosts, hosts)

FastGlobal.get(:hosts)
```

---

# FastGlobal

- Data is compiled into module constant
- Easy, fast
- Compilation slows down with data size
- Kind of a hack
- Updates require recompilation
- External library
- Data is not copied to caller

---

# persistent_term

```elixir
hosts = %{...}

:persistent_term.put({HostsModule, :hosts}, hosts)

:persistent_term.get({HostsModule, :hosts})

true = :persistent_term.erase({HostsModule, :hosts})
```

---


# persistent_term

- new in OTP 21.2 (December 2018)
- Big mutable global hash table
- Easy, fast
- Not GC'd
- Built in
- Updates are very expensive
- Best for few, larger data
- Data is not copied to caller

---

# persistent_term - Warning!

> Persistent terms is an advanced feature and is not a general replacement for ETS tables. Before using persistent terms, make sure to fully understand the consequence to system performance when updating or deleting persistent terms.
-- the OTP gods

---

# persistent_term considered dangerous

On term deletion or replacement...

> All processes in the system will be scheduled to run a scan of their heaps for the term that has been deleted. While such scan is relatively light-weight, if there are many processes, the system can become less responsive until all process have scanned their heaps.
-- the OTP gods


---

| ###             | GenServer | ETS       | FastGlobal | persistent_term |
| ---             | --------- | ---       | ---------- | --------------- |
| difficulty      | easy      | easy      | easy       | easy            |
| 1 read perf     | medium    | fast      | fast       | very fast       |
| 1 write perf    | medium    | fast      | very slow  | very slow       |
| many read perf  | slow      | fast      | fast       | very fast       |
| many write perf | slow      | fast      | very slow  | very slow       |
| builtin?        | yes       | yes       | no         | yes             |
| lookup          | anything  | hashtable | hashtable  | hashtable       |
| distributed     | can be    | no        | no         | no              |



---





---

