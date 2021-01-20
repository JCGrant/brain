defmodule Utils do
  def maybe_map(nil, _f), do: nil
  def maybe_map(x, f), do: f.(x)

  def map_by(elems, key) do
    Enum.reduce(elems, %{}, fn el, acc -> Map.put(acc, Map.get(el, key), el) end)
  end
end
