defmodule GoogleAuth.Config do
  use Goth.Config

  def init(config) do
    google_credentials = GoogleAuth.get_google_credentials()
    refresh_token = Application.fetch_env!(:brain, :google_refresh_token)

    goth_json =
      Map.put(google_credentials, :refresh_token, refresh_token)
      |> Jason.encode!()

    {:ok, Keyword.put(config, :json, goth_json)}
  end
end
