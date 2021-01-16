defmodule BrainTest do
  use ExUnit.Case
  alias Brain.TrelloCalendar.TodoTask, as: TodoTask
  doctest Brain

  test "checks updated task lists" do
    tests = [
      {
        "empty",
        %{},
        %{},
        [new: [], updated: [], deleted: []]
      },
      {
        "add new to empty",
        %{},
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z")
        },
        [
          new: [
            TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z")
          ],
          updated: [],
          deleted: []
        ]
      },
      {
        "add multiple",
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z")
        },
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z"),
          "2" => TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z"),
          "3" => TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z")
        },
        [
          new: [
            TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z"),
            TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z")
          ],
          updated: [],
          deleted: []
        ]
      },
      {
        "update task due time",
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z")
        },
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-2T00:00:00.000Z")
        },
        [
          new: [],
          updated: [
            TodoTask.new("1", "task 1", "2021-01-2T00:00:00.000Z")
          ],
          deleted: []
        ]
      },
      {
        "update multiple",
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z"),
          "2" => TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z"),
          "3" => TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z")
        },
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z"),
          "2" => TodoTask.new("2", "task 4", "2021-01-4T00:00:00.000Z"),
          "3" => TodoTask.new("3", "task 5", "2021-01-5T00:00:00.000Z")
        },
        [
          new: [],
          updated: [
            TodoTask.new("2", "task 4", "2021-01-4T00:00:00.000Z"),
            TodoTask.new("3", "task 5", "2021-01-5T00:00:00.000Z")
          ],
          deleted: []
        ]
      },
      {
        "delete task",
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z")
        },
        %{},
        [
          new: [],
          updated: [],
          deleted: [
            TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z")
          ]
        ]
      },
      {
        "delete multiple",
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z"),
          "2" => TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z"),
          "3" => TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z")
        },
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z")
        },
        [
          new: [],
          updated: [],
          deleted: [
            TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z"),
            TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z")
          ]
        ]
      },
      {
        "add, update, and delete",
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z"),
          "2" => TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z")
        },
        %{
          "1" => TodoTask.new("1", "task 4", "2021-01-4T00:00:00.000Z"),
          "3" => TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z")
        },
        [
          new: [
            TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z")
          ],
          updated: [
            TodoTask.new("1", "task 4", "2021-01-4T00:00:00.000Z")
          ],
          deleted: [
            TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z")
          ]
        ]
      },
      {
        "add, update, and delete multiple",
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z"),
          "2" => TodoTask.new("2", "task 2", "2021-01-2T00:00:00.000Z"),
          "3" => TodoTask.new("3", "task 3", "2021-01-3T00:00:00.000Z"),
          "4" => TodoTask.new("4", "task 4", "2021-01-4T00:00:00.000Z"),
          "5" => TodoTask.new("5", "task 5", "2021-01-5T00:00:00.000Z")
        },
        %{
          "1" => TodoTask.new("1", "task 1", "2021-01-1T00:00:00.000Z"),
          "2" => TodoTask.new("2", "task 8", "2021-01-8T00:00:00.000Z"),
          "3" => TodoTask.new("3", "task 9", "2021-01-9T00:00:00.000Z"),
          "6" => TodoTask.new("6", "task 6", "2021-01-6T00:00:00.000Z"),
          "7" => TodoTask.new("7", "task 7", "2021-01-7T00:00:00.000Z")
        },
        [
          new: [
            TodoTask.new("6", "task 6", "2021-01-6T00:00:00.000Z"),
            TodoTask.new("7", "task 7", "2021-01-7T00:00:00.000Z")
          ],
          updated: [
            TodoTask.new("2", "task 8", "2021-01-8T00:00:00.000Z"),
            TodoTask.new("3", "task 9", "2021-01-9T00:00:00.000Z")
          ],
          deleted: [
            TodoTask.new("4", "task 4", "2021-01-4T00:00:00.000Z"),
            TodoTask.new("5", "task 5", "2021-01-5T00:00:00.000Z")
          ]
        ]
      }
    ]

    Enum.each(tests, fn {_name, previous_tasks, tasks, result} ->
      assert Brain.TrelloCalendar.diff_tasks(previous_tasks, tasks) == result
    end)
  end
end
