defmodule Brain.Todo.Parsers do
  alias Brain.Todo.Task

  def trello_card_to_task(card) do
    cond do
      card.due == nil ->
        {:error, "card is missing due date"}

      card.custom_field_items == [] ->
        {:error, "card is missing end date custom field"}

      true ->
        {:ok,
         %Task{
           id: card.id,
           name: card.name,
           time: %{
             start:
               card.due
               |> DateTime.truncate(:second),
             end:
               (card.custom_field_items |> Enum.at(0)).value.date
               |> DateTime.truncate(:second)
           }
         }}
    end
  end

  def task_to_trello_card(task) do
    %Trello.Model.Card{
      id: task.id,
      name: task.name,
      due: task.time.start,
      custom_field_items: [
        %Trello.Model.CustomFieldItem{
          id_custom_field:
            Application.fetch_env!(:brain, :trello_end_date_custom_field_id),
          value: %{
            date: task.time.end
          }
        }
      ]
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
