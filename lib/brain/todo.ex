defmodule Brain.Todo do
  use GenServer

  require Logger

  alias Brain.Todo.Parsers
  alias Brain.Todo.Diff

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    send(self(), :check_tasks)
    {:ok, state}
  end

  defp get_tasks(source_fn, args, parser_fn) do
    apply(source_fn, args)
    |> Enum.flat_map(fn elem ->
      case parser_fn.(elem) do
        {:ok, task} -> [task]
        {:error, _} -> []
      end
    end)
    |> Utils.map_by(:id)
  end

  defp check_tasks(tasks) do
    board_id = Application.fetch_env!(:brain, :trello_board_id)
    google_calendar_id = Application.fetch_env!(:brain, :google_calendar_id)

    end_date_custom_field_id =
      Application.fetch_env!(:brain, :trello_end_date_custom_field_id)

    current_trello_tasks =
      get_tasks(
        &Trello.Api.Boards.get_cards/1,
        [board_id],
        &Parsers.trello_card_to_task/1
      )

    trello_diff = Diff.diff_tasks(tasks, current_trello_tasks)

    Enum.each(trello_diff.created, fn task ->
      Logger.log(:info, "created trello task: #{inspect(task)}")
      event = Parsers.task_to_google_calendar_event(task)
      GoogleCalendar.create_event(google_calendar_id, event)
    end)

    Enum.each(trello_diff.updated, fn task ->
      Logger.log(:info, "updated trello task: #{inspect(task)}")
      event = Parsers.task_to_google_calendar_event(task)
      GoogleCalendar.update_event(google_calendar_id, event.id, event)
    end)

    Enum.each(trello_diff.deleted, fn task ->
      Logger.log(:info, "deleted trello task: #{inspect(task)}")
      event = Parsers.task_to_google_calendar_event(task)
      GoogleCalendar.delete_event(google_calendar_id, event.id)
    end)

    current_google_calendar_tasks =
      get_tasks(
        &GoogleCalendar.get_events/1,
        [google_calendar_id],
        &Parsers.google_calendar_event_to_task/1
      )

    # Compare with current_trello_tasks or we will get an updated calendar event
    google_calendar_diff =
      Diff.diff_tasks(current_trello_tasks, current_google_calendar_tasks)

    Enum.each(google_calendar_diff.updated, fn task ->
      Logger.log(:info, "updated google calendar task: #{inspect(task)}")
      card = Parsers.task_to_trello_card(task)

      Trello.Api.Cards.update_card(card.id, %{
        name: card.name,
        due: card.due
      })

      Trello.Api.Cards.update_custom_field_item(
        card.id,
        end_date_custom_field_id,
        card.custom_field_items |> Enum.at(0)
      )
    end)

    Map.merge(current_trello_tasks, current_google_calendar_tasks)
  end

  @impl true
  def handle_info(:check_tasks, tasks) do
    new_tasks = check_tasks(tasks)
    Process.send_after(self(), :check_tasks, 1000)
    {:noreply, new_tasks}
  end
end
