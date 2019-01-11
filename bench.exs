# only reads

# SERVER

small_simple = 0..10 |> Enum.map(fn n -> {to_string(n), to_string(n)} end) |> Enum.into(%{})
medium_simple = 0..10_000 |> Enum.map(fn n -> {to_string(n), to_string(n)} end) |> Enum.into(%{})

large_simple =
  0..1_000_000 |> Enum.map(fn n -> {to_string(n), to_string(n)} end) |> Enum.into(%{})

# small_lookup = Enum.map(0..10, fn n -> to_string(:rand.uniform(10)) end)
# medium_lookup = Enum.map(0..10_000, fn n -> to_string(:rand.uniform(10_000)) end)
# large_lookup = Enum.map(0..1_000_000, fn n -> to_string(:rand.uniform(1_000_000)) end)

alias Pterm.MapServer

{:ok, small_server} = MapServer.start_link(%{data: small_simple})
{:ok, medium_server} = MapServer.start_link(%{data: medium_simple})
{:ok, large_server} = MapServer.start_link(%{data: large_simple})

# ETS

:ets.new(:small_table, [{:read_concurrency, true}, :named_table])
:ets.new(:medium_table, [{:read_concurrency, true}, :named_table])
:ets.new(:large_table, [{:read_concurrency, true}, :named_table])

# 0..10
# |> Enum.map(fn n -> {to_string(n), to_string(n)} end)
# |> Enum.each(fn t -> :ets.insert(:small_table, t) end)

# 0..10_000
# |> Enum.map(fn n -> {to_string(n), to_string(n)} end)
# |> Enum.each(fn t -> :ets.insert(:medium_table, t) end)

# 0..1_000_000
# |> Enum.map(fn n -> {to_string(n), to_string(n)} end)
# |> Enum.each(fn t -> :ets.insert(:large_table, t) end)

:ets.insert(:small_table, {:benchmark, small_simple})
:ets.insert(:medium_table, {:benchmark, medium_simple})
:ets.insert(:large_table, {:benchmark, large_simple})

:persistent_term.put({:benchmark, :small}, small_simple)
:persistent_term.put({:benchmark, :medium}, medium_simple)
:persistent_term.put({:benchmark, :large}, large_simple)

Benchee.run(
  %{
    "genserver small" => fn ->
      MapServer.get(small_server) |> Map.fetch!(to_string(:rand.uniform(10)))
    end,
    "genserver medium" => fn ->
      MapServer.get(medium_server) |> Map.fetch!(to_string(:rand.uniform(10_000)))
    end,
    "genserver large" => fn ->
      MapServer.get(large_server) |> Map.fetch!(to_string(:rand.uniform(1_000_000)))
    end,
    "ets small" => fn ->
      [{:benchmark, m}] = :ets.lookup(:small_table, :benchmark)
      m |> Map.fetch!(to_string(:rand.uniform(10)))
    end,
    "ets medium" => fn ->
      [{:benchmark, m}] = :ets.lookup(:medium_table, :benchmark)
      m |> Map.fetch!(to_string(:rand.uniform(10_000)))
    end,
    "ets large" => fn ->
      [{:benchmark, m}] = :ets.lookup(:large_table, :benchmark)
      m |> Map.fetch!(to_string(:rand.uniform(1_000_000)))
    end,
    "peristent_term small" => fn ->
      :persistent_term.get({:benchmark, :small}) |> Map.fetch!(to_string(:rand.uniform(10)))
    end,
    "peristent_term medium" => fn ->
      :persistent_term.get({:benchmark, :medium})
      |> Map.fetch!(to_string(:rand.uniform(10_000)))
    end,
    "peristent_term large" => fn ->
      :persistent_term.get({:benchmark, :large})
      |> Map.fetch!(to_string(:rand.uniform(1_000_000)))
    end
  },
  # memory_time: 2,
  parallel: 60,
  print: [fast_warning: false]
)
