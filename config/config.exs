import Config

config :brain,
  # https://console.developers.google.com/apis/credentials?project=jcgrant-brain
  google_credentials_path: "config/secret/google_credentials.json",
  # https://developers.google.com/identity/protocols/oauth2/scopes
  google_scopes: [
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/calendar.events"
  ],
  google_refresh_token: "config/secret/refresh_token.txt" |> File.read!

config :goth,
  config_module: GoogleAuth.Config

import_config "secret/config.exs"
