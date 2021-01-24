defmodule Trello.Model do
  @type custom_field_item_value :: %{
          text: String.t() | nil,
          number: number | nil,
          checked: boolean | nil,
          date: DateTime.t() | nil
        }

  @type card_update_payload :: %{
          name: String.t() | nil,
          due: DateTime.t() | nil
        }

  @type custom_field_item_value_update_payload :: %{
          value: custom_field_item_value | nil,
          idValue: String.t() | nil
        }

  defmodule CustomFieldItem do
    use TypedStruct

    typedstruct do
      field(:id_custom_field, String.t(), enforce: true)
      field(:value, Trello.Model.custom_field_item_value(), enforce: true)
    end

    def from_map(json) do
      %CustomFieldItem{
        id_custom_field: json["idCustomField"],
        value: %{
          date: json["value"]["date"] |> DateTime.from_iso8601() |> elem(1)
        }
      }
    end
  end

  defmodule Card do
    use TypedStruct

    typedstruct do
      field(:id, String.t(), enforce: true)
      field(:name, String.t(), enforce: true)
      field(:due, DateTime.t())

      field(
        :custom_field_items,
        [CustomFieldItem],
        enforce: true
      )
    end

    def from_map(json) do
      %Card{
        id: json["id"],
        name: json["name"],
        due:
          Utils.maybe_map(json["due"], fn due ->
            due |> DateTime.from_iso8601() |> elem(1)
          end),
        custom_field_items:
          (json["customFieldItems"] || [])
          |> Enum.map(&CustomFieldItem.from_map/1)
      }
    end
  end
end
