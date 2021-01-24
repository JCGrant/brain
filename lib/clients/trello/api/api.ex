defmodule Trello.Api do
  def key do
    Application.fetch_env!(:brain, :trello_key)
  end

  def token do
    Application.fetch_env!(:brain, :trello_token)
  end

  defmodule Boards do
    def get_cards(board_id) do
      HTTPoison.get!(
        "https://api.trello.com/1/boards/#{board_id}/cards?key=#{
          Trello.Api.key()
        }&token=#{Trello.Api.token()}&customFieldItems=true"
      ).body
      |> Jason.decode!()
      |> Enum.map(&Trello.Model.Card.from_map/1)
    end
  end

  defmodule Cards do
    def get_card(card_id) do
      HTTPoison.get!(
        "https://api.trello.com/1/cards/#{card_id}?key=#{Trello.Api.key()}&token=#{
          Trello.Api.token()
        }&customFieldItems=true"
      ).body
      |> Jason.decode!()
      |> Trello.Model.Card.from_map()
    end

    def update_card(card_id, payload) do
      HTTPoison.put!(
        "https://api.trello.com/1/cards/#{card_id}?key=#{Trello.Api.key()}&token=#{
          Trello.Api.token()
        }&#{URI.encode_query(payload)}"
      ).body
      |> Jason.decode!()
      |> Trello.Model.Card.from_map()
    end

    def get_custom_field_items(card_id) do
      HTTPoison.get!(
        "https://api.trello.com/1/cards/#{card_id}/customFieldItems?key=#{
          Trello.Api.key()
        }&token=#{Trello.Api.token()}"
      ).body
      |> Jason.decode!()
      |> Enum.map(&Trello.Model.CustomFieldItem.from_map/1)
    end

    def update_custom_field_item(
          card_id,
          custom_field_id,
          payload
        ) do
      HTTPoison.put!(
        "https://api.trello.com/1/cards/#{card_id}/customField/#{
          custom_field_id
        }/item?key=#{Trello.Api.key()}&token=#{Trello.Api.token()}",
        Jason.encode!(Map.from_struct(payload)),
        [{"Content-type", "application/json"}]
      ).body
      |> Jason.decode!()
      |> Trello.Model.CustomFieldItem.from_map()
    end
  end
end
