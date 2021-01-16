defmodule Brain.TrelloCalendar do
  use GenServer

  defmodule TodoTask do
    defstruct id: "", name: "", due: ""

    def new(id, name, due) do
      %TodoTask{id: id, name: name, due: due}
    end
  end

  def start_link(_state) do
    HTTPoison.start()
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(tasks) do
    send(self(), :check_trello)
    {:ok, tasks}
  end

  @impl true
  def handle_info(:check_trello, tasks) do
    new_tasks = check_trello(tasks)
    Process.send_after(self(), :check_trello, 1000)
    {:noreply, new_tasks}
  end

  def check_trello(tasks) do
    current_trello_tasks = get_trello_tasks()
    diff = diff_tasks(tasks, current_trello_tasks)
    IO.inspect(diff)
    current_trello_tasks
  end

  def check_new_tasks(previous_tasks, tasks) do
    Map.values(tasks)
    |> Enum.filter(fn task -> !Map.has_key?(previous_tasks, task.id) end)
  end

  def check_deleted_tasks(previous_tasks, tasks) do
    check_new_tasks(tasks, previous_tasks)
  end

  def check_updated_tasks(previous_tasks, tasks) do
    Map.values(tasks)
    |> Enum.filter(fn task ->
      previous_tasks[task.id] != nil && previous_tasks[task.id] != task
    end)
  end

  def diff_tasks(previous_tasks, tasks) do
    [
      new: check_new_tasks(previous_tasks, tasks),
      updated: check_updated_tasks(previous_tasks, tasks),
      deleted: check_deleted_tasks(previous_tasks, tasks)
    ]
  end

  def get_trello_tasks do
    id = Application.fetch_env!(:brain, :trello_board_id)
    key = Application.fetch_env!(:brain, :trello_key)
    token = Application.fetch_env!(:brain, :trello_token)

    HTTPoison.get!(
      "https://api.trello.com/1/boards/#{id}/cards?fields=name,due&key=#{key}&token=#{token}"
    ).body
    |> Jason.decode!()
    |> Enum.map(fn obj -> TodoTask.new(obj["id"], obj["name"], obj["due"]) end)
    |> Enum.reduce(%{}, fn task, acc -> Map.put(acc, task.id, task) end)
  end
end
