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
           url: card.url,
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
      url: task.url,
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

  @trello_url_regex ~r/https:\/\/trello.com\/c\/[a-zA-Z0-9]+\/[0-9]+(-[a-z0-9]+)+/

  defp extract_trello_url(string) do
    case Regex.run(@trello_url_regex, string) do
      [url | _] -> {:ok, url}
      _ -> {:error, :no_url}
    end
  end

  def google_calendar_event_to_task(event) do
    if event.description == nil do
      {:error, "no description"}
    else
      case extract_trello_url(event.description) do
        {:error, :no_url} ->
          {:error, "no trello url found"}

        {:ok, url} ->
          {:ok,
           %Task{
             id: event.id,
             name: event.summary,
             url: url,
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
  end

  def task_to_google_calendar_event(task) do
    %GoogleApi.Calendar.V3.Model.Event{
      id: task.id,
      summary: task.name,
      description: task.url,
      start: %GoogleApi.Calendar.V3.Model.EventDateTime{
        dateTime: task.time.start
      },
      end: %GoogleApi.Calendar.V3.Model.EventDateTime{
        dateTime: task.time.end
      }
    }
  end
end
