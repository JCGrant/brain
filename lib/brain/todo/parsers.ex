defmodule Brain.Todo.Parsers do
  alias Brain.Todo.Task

  def trello_card_to_task(card) do
    try do
      %{"end_time" => end_time_str} = Jason.decode!(card.desc)
      {:ok, end_time, _} = DateTime.from_iso8601(end_time_str)

      {:ok,
       %Task{
         id: card.id,
         name: card.name,
         time: %{
           start:
             card.due
             |> DateTime.truncate(:second),
           end:
             end_time
             |> DateTime.truncate(:second)
         }
       }}
    rescue
      e in Jason.DecodeError -> {:error, e}
    end
  end

  def task_to_trello_card(task) do
    description = Jason.encode!(%{"end_time" => task.time.end})

    %Trello.Card{
      id: task.id,
      name: task.name,
      desc: description,
      due: task.time.start
    }
  end

  def google_calendar_event_to_task(event) do
    if event.description != "trello" do
      {:error, "event not synced with trello"}
    else
      {:ok,
       %Task{
         id: event.id,
         name: event.summary,
         time: %{
           start:
             event.start.dateTime
             |> DateTime.truncate(:second),
           end:
             event.end.dateTime
             |> DateTime.truncate(:second)
         }
       }}
    end
  end

  def task_to_google_calendar_event(task) do
    %GoogleApi.Calendar.V3.Model.Event{
      id: task.id,
      summary: task.name,
      description: "trello",
      start: %GoogleApi.Calendar.V3.Model.EventDateTime{
        dateTime: task.time.start
      },
      end: %GoogleApi.Calendar.V3.Model.EventDateTime{
        dateTime: task.time.end
      }
    }
  end
end
