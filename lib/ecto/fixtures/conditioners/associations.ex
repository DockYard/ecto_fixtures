defmodule EctoFixtures.Conditioners.Associations do
  import EctoFixtures.Conditioners.PrimaryKey, only: [generate_key_value: 3]

  def process(data, path) do
    table_path = path |> Enum.take(2)
    model = get_in(data, table_path ++ [:model])

    model.__schema__(:associations)
    |> Enum.reduce data, fn(association_name, data) ->
      if get_in(data, path ++ [:data, association_name]) do
        case model.__schema__(:association, association_name) do
          %Ecto.Association.Has{} = association ->
            has_association(data, path, association)
          %Ecto.Association.BelongsTo{} = association ->
            belongs_to_association(data, path, association)
        end
      else
        data
      end
    end
  end

  defp has_association(data, path, %{cardinality: :one} = association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    association_path = get_in(data, path ++ [:data, field]) |> get_path
    association_path = [List.first(path) | association_path]
    data = generate_key_value(data, path, owner_key)
    owner_key_value = get_in(data, path ++ [:data, owner_key])
    put_in(data, association_path ++ [related_key], owner_key_value)
    |> put_in(path ++ [:data], Map.delete(get_in(data, path ++ [:data]), field))
  end

  defp has_association(data, path, %{cardinality: :many} = association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    data = Enum.reduce get_in(data, path ++ [:data, field]), data, fn(association_expr, data) ->
      association_path = get_path(association_expr)
      association_path = [List.first(path) | association_path]
      data = generate_key_value(data, path, owner_key)
      owner_key_value = get_in(data, path ++ [:data, owner_key])
      put_in(data, association_path ++ [related_key], owner_key_value)
    end
    put_in(data, path ++ [:data], Map.delete(get_in(data, path ++ [:data]), field))
  end

  defp belongs_to_association(data, path, association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    [related_table_name, _, related_row_name, _] = get_in(data, path ++ [:data, field]) |> get_path

    related_path =
      path
      |> List.replace_at(1, related_table_name)
      |> List.replace_at(3, related_row_name)

    data = generate_key_value(data, related_path, related_key)
    related_key_value = get_in(data, related_path ++ [:data, related_key])
    data = put_in(data, path ++ [:data, owner_key], related_key_value)
    put_in(data, path ++ [:data], Map.delete(get_in(data, path ++ [:data]), field))
  end

  defp get_path({{:., _, [{table_name, _, _}, row_name]}, _, _}) do
    [table_name, :rows, row_name, :data]
  end
end
