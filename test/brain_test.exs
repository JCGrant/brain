defmodule BrainTest do
  use ExUnit.Case
  doctest Brain
  alias Brain.Todo.Task

  ExUnit.Case.register_attribute(__ENV__, :test)

  describe "diff_tasks" do
    task_1 = %Task{
      id: "1",
      name: "task 1",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_1_with_different_datetime_decimals = %Task{
      id: "1",
      name: "task 1",
      time: %{
        start: ~U[2020-01-01 00:00:00.00Z],
        end: ~U[2020-01-01 00:00:00.00Z]
      }
    }

    task_2 = %Task{
      id: "2",
      name: "task 2",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_3 = %Task{
      id: "3",
      name: "task 3",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_4 = %Task{
      id: "4",
      name: "task 4",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_5 = %Task{
      id: "5",
      name: "task 5",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_6 = %Task{
      id: "6",
      name: "task 6",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_7 = %Task{
      id: "7",
      name: "task 7",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_1_updated = %Task{
      id: "1",
      name: "task 1 updated",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_2_updated = %Task{
      id: "2",
      name: "task 2 updated",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    task_3_updated = %Task{
      id: "3",
      name: "task 3 updated",
      time: %{
        start: ~U[2020-01-01 00:00:00.000Z],
        end: ~U[2020-01-01 00:00:00.000Z]
      }
    }

    tests = [
      {
        "empty",
        {
          %{},
          %{},
          %{created: [], updated: [], deleted: []}
        }
      },
      {
        "create task",
        {
          %{},
          %{
            "1" => task_1
          },
          %{
            created: [
              task_1
            ],
            updated: [],
            deleted: []
          }
        }
      },
      {
        "create multiple",
        {
          %{
            "1" => task_1
          },
          %{
            "1" => task_1,
            "2" => task_2,
            "3" => task_3
          },
          %{
            created: [
              task_2,
              task_3
            ],
            updated: [],
            deleted: []
          }
        }
      },
      {
        "update task",
        {
          %{
            "1" => task_1
          },
          %{
            "1" => task_1_updated
          },
          %{
            created: [],
            updated: [
              task_1_updated
            ],
            deleted: []
          }
        }
      },
      {
        "update multiple",
        {
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
          %{
            created: [],
            updated: [task_2_updated, task_3_updated],
            deleted: []
          }
        }
      },
      {
        "update with different DateTime decimals",
        {
          %{
            "1" => task_1
          },
          %{
            "1" => task_1_with_different_datetime_decimals
          },
          %{
            created: [],
            updated: [],
            deleted: []
          }
        }
      },
      {
        "delete task",
        {
          %{
            "1" => task_1
          },
          %{},
          %{
            created: [],
            updated: [],
            deleted: [task_1]
          }
        }
      },
      {
        "delete multiple",
        {
          %{
            "1" => task_1,
            "2" => task_2,
            "3" => task_3
          },
          %{
            "1" => task_1
          },
          %{
            created: [],
            updated: [],
            deleted: [task_2, task_3]
          }
        }
      },
      {
        "add, update, and delete",
        {
          %{
            "1" => task_1,
            "2" => task_2
          },
          %{
            "1" => task_1_updated,
            "3" => task_3
          },
          %{
            created: [task_3],
            updated: [task_1_updated],
            deleted: [task_2]
          }
        }
      },
      {
        "add, update, and delete multiple",
        {
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
          %{
            created: [task_6, task_7],
            updated: [task_2_updated, task_3_updated],
            deleted: [task_4, task_5]
          }
        }
      }
    ]

    for {name, test} <- tests do
      @test test
      test name, context do
        {previous_tasks, tasks, result} = context.registered.test

        assert Brain.Todo.Diff.diff_tasks(
                 previous_tasks,
                 tasks
               ) == result
      end
    end
  end
end
