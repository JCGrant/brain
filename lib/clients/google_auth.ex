defmodule GoogleAuth do
  @google_credentials Application.fetch_env!(:brain, :google_credentials_path)
                      |> File.read!()
                      |> Jason.decode!()
                      |> Map.get("web")

  def get_google_credentials do
    @google_credentials
  end

  @doc """
  https://developers.google.com/identity/protocols/oauth2/web-server
  """
  def get_refresh_token do
    %{
      "client_id" => client_id,
      "client_secret" => client_secret,
      "auth_uri" => auth_uri,
      "token_uri" => token_uri,
      "redirect_uris" => [redirect_uri]
    } = get_google_credentials()

    scope = Application.fetch_env!(:brain, :google_scopes) |> Enum.join("+")

    auth_url =
      "#{auth_uri}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{
        scope
      }&access_type=offline&prompt=consent"

    IO.puts(
      "Opening the following link, and enter the URL you are redirected to below"
    )

    IO.puts(auth_url)

    auth_code =
      IO.gets("> ")
      |> URI.parse()
      |> Map.get(:query)
      |> URI.decode_query()
      |> Map.get("code")

    %{"refresh_token" => refresh_token} =
      HTTPoison.post!(
        token_uri,
        Jason.encode!(%{
          code: auth_code,
          client_id: client_id,
          client_secret: client_secret,
          redirect_uri: redirect_uri,
          grant_type: "authorization_code"
        })
      ).body
      |> Jason.decode!()

    IO.puts(refresh_token)
  end
end
