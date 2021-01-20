defmodule Brain.Todo.Task do
  use TypedStruct

  typedstruct enforce: true do
    field(:id, String.t())
    field(:name, String.t())
    field(:time, %{start: DateTime.t(), end: DateTime.t()})
  end

  def equals(task1, task2) do
    task1.id == task2.id &&
      task1.name == task2.name &&
      DateTime.compare(task1.time.start, task2.time.start) == :eq &&
      DateTime.compare(task1.time.end, task2.time.end) == :eq
  end
end
