defmodule Brain.Todo.Diff do
  alias Brain.Todo.Task

  defp check_created_tasks(previous_tasks, tasks) do
    Map.values(tasks)
    |> Enum.filter(fn task -> !Map.has_key?(previous_tasks, task.id) end)
  end

  defp check_updated_tasks(previous_tasks, tasks) do
    Map.values(tasks)
    |> Enum.filter(fn task ->
      previous_tasks[task.id] != nil &&
        !Task.equals(previous_tasks[task.id], task)
    end)
  end

  defp check_deleted_tasks(previous_tasks, tasks) do
    check_created_tasks(tasks, previous_tasks)
  end

  def diff_tasks(previous_tasks, tasks) do
    %{
      created: check_created_tasks(previous_tasks, tasks),
      updated: check_updated_tasks(previous_tasks, tasks),
      deleted: check_deleted_tasks(previous_tasks, tasks)
    }
  end
end
