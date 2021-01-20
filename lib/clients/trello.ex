defmodule Trello do
  defmodule Card do
    use TypedStruct

    typedstruct do
      field(:id, String.t(), enforce: true)
      field(:name, Stirng.t(), enforce: true)
      field(:desc, String.t(), enforce: true)
      field(:due, DateTime.t())
    end

    def from_json(json) do
      %Card{
        id: json["id"],
        name: json["name"],
        desc: json["desc"],
        due:
          Utils.maybe_map(json["due"], fn due ->
            due |> DateTime.from_iso8601() |> elem(1)
          end)
      }
    end
  end

  @key Application.fetch_env!(:brain, :trello_key)
  @token Application.fetch_env!(:brain, :trello_token)

  @spec get_cards(String.t()) :: [Card.t()]
  def get_cards(board_id) do
    HTTPoison.get!(
      "https://api.trello.com/1/boards/#{board_id}/cards?key=#{@key}&token=#{
        @token
      }"
    ).body
    |> Jason.decode!()
    |> Enum.map(&Card.from_json/1)
  end

  @spec update_card(String.t(), Card.t()) :: Card.t()
  def update_card(card_id, card) do
    HTTPoison.put!(
      "https://api.trello.com/1/cards/#{card_id}?key=#{@key}&token=#{@token}&#{
        URI.encode_query(Map.from_struct(card))
      }"
    ).body
    |> Jason.decode!()
    |> Card.from_json()
  end
end
