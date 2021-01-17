defmodule BrainTest do
  use ExUnit.Case
  alias Brain.TrelloCalendar.TodoTask, as: TodoTask
  doctest Brain

  test "checks updated task lists" do
    task_1 =
      TodoTask.new("1", "task 1", %{
        start: "2021-01-1T00:00:00.000Z",
        end: "2021-01-1T01:00:00.000Z"
      })

    task_2 =
      TodoTask.new("2", "task 2", %{
        start: "2021-01-1T00:00:00.000Z",
        end: "2021-01-1T01:00:00.000Z"
      })

    task_3 =
      TodoTask.new("3", "task 3", %{
        start: "2021-01-1T00:00:00.000Z",
        end: "2021-01-1T01:00:00.000Z"
      })

    task_4 =
      TodoTask.new("4", "task 4", %{
        start: "2021-01-1T00:00:00.000Z",
        end: "2021-01-1T01:00:00.000Z"
      })

    task_5 =
      TodoTask.new("5", "task 5", %{
        start: "2021-01-1T00:00:00.000Z",
        end: "2021-01-1T01:00:00.000Z"
      })

    task_6 =
      TodoTask.new("6", "task 6", %{
        start: "2021-01-1T00:00:00.000Z",
        end: "2021-01-1T01:00:00.000Z"
      })

    task_7 =
      TodoTask.new("7", "task 7", %{
        start: "2021-01-1T00:00:00.000Z",
        end: "2021-01-1T01:00:00.000Z"
      })

    task_1_updated =
      TodoTask.new("1", "task 1 updated", {"2021-01-1T00:00:00.000Z", "2021-01-1T01:00:00.000Z"})

    task_2_updated =
      TodoTask.new("2", "task 2 updated", {"2021-01-1T00:00:00.000Z", "2021-01-1T01:00:00.000Z"})

    task_3_updated =
      TodoTask.new("3", "task 3 updated", {"2021-01-1T00:00:00.000Z", "2021-01-1T01:00:00.000Z"})

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
          "1" => task_1
        },
        [
          new: [
            task_1
          ],
          updated: [],
          deleted: []
        ]
      },
      {
        "add multiple",
        %{
          "1" => task_1
        },
        %{
          "1" => task_1,
          "2" => task_2,
          "3" => task_3
        },
        [
          new: [
            task_2,
            task_3
          ],
          updated: [],
          deleted: []
        ]
      },
      {
        "update task due time",
        %{
          "1" => task_1
        },
        %{
          "1" => task_1_updated
        },
        [
          new: [],
          updated: [
            task_1_updated
          ],
          deleted: []
        ]
      },
      {
        "update multiple",
        %{
          "1" => task_1,
          "2" => task_2,
          "3" => task_3
        },
        %{
          "1" => task_1,
          "2" => task_2_updated,
          "3" => task_3_updated
        },
        [
          new: [],
          updated: [task_2_updated, task_3_updated],
          deleted: []
        ]
      },
      {
        "delete task",
        %{
          "1" => task_1
        },
        %{},
        [
          new: [],
          updated: [],
          deleted: [task_1]
        ]
      },
      {
        "delete multiple",
        %{
          "1" => task_1,
          "2" => task_2,
          "3" => task_3
        },
        %{
          "1" => task_1
        },
        [
          new: [],
          updated: [],
          deleted: [task_2, task_3]
        ]
      },
      {
        "add, update, and delete",
        %{
          "1" => task_1,
          "2" => task_2
        },
        %{
          "1" => task_1_updated,
          "3" => task_3
        },
        [
          new: [task_3],
          updated: [task_1_updated],
          deleted: [task_2]
        ]
      },
      {
        "add, update, and delete multiple",
        %{
          "1" => task_1,
          "2" => task_2,
          "3" => task_3,
          "4" => task_4,
          "5" => task_5
        },
        %{
          "1" => task_1,
          "2" => task_2_updated,
          "3" => task_3_updated,
          "6" => task_6,
          "7" => task_7
        },
        [
          new: [task_6, task_7],
          updated: [task_2_updated, task_3_updated],
          deleted: [task_4, task_5]
        ]
      }
    ]

    Enum.each(tests, fn {_name, previous_tasks, tasks, result} ->
      assert Brain.TrelloCalendar.diff_tasks(previous_tasks, tasks) == result
    end)
  end
end
