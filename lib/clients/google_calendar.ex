defmodule GoogleCalendar do
  @scope Application.fetch_env!(:brain, :google_scopes) |> Enum.join(" ")

  defp get_conn do
    {:ok, token} = Goth.Token.for_scope(@scope)
    GoogleApi.Calendar.V3.Connection.new(token.token)
  end

  def get_events(calendar_id) do
    {:ok, events} =
      GoogleApi.Calendar.V3.Api.Events.calendar_events_list(
        get_conn(),
        calendar_id,
        maxResults: 2500
      )

    events.items
  end

  def create_event(calendar_id, body) do
    GoogleApi.Calendar.V3.Api.Events.calendar_events_insert(
      get_conn(),
      calendar_id,
      body: body
    )
  end

  def update_event(calendar_id, event_id, body) do
    GoogleApi.Calendar.V3.Api.Events.calendar_events_update(
      get_conn(),
      calendar_id,
      event_id,
      body: body
    )
  end

  def delete_event(calendar_id, event_id) do
    GoogleApi.Calendar.V3.Api.Events.calendar_events_delete(
      get_conn(),
      calendar_id,
      event_id
    )
  end
end
