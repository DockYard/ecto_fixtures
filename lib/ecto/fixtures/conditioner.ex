defmodule EctoFixtures.Conditioner do
  @max_id trunc(:math.pow(2, 30) - 1)

  def condition(data, opts) do
    Enum.reduce data, data, fn({path, _}, data) ->
      condition_tables(data, [path], opts)
    end
  end

  def condition_tables(data, path, opts) do
    Enum.reduce get_in(data, path), data, fn({table_name, _}, data) ->
      condition_table(data, path ++ [table_name, :rows], opts)
    end
  end

  defp condition_table(data, path, opts) do
    Enum.reduce get_in(data, path), data, fn({row_name, _}, data) ->
      condition_row(data, path ++ [row_name], opts)
    end
  end

  defp condition_row(data, path, opts) do
    data
    |> override(opts)
    |> condition_inheritance(path)
    |> condition_primary_key(path)
    |> condition_associations(path)
    |> condition_function_calls(path)
  end

  defp override(data, [source: source, override: %{}=override_data]) do
    Enum.reduce override_data, data, fn({table_name, rows}, data) ->
      case get_in(data, [source, table_name]) do
        nil -> data
        _ -> Enum.reduce rows, data, fn({row_name, columns}, data) ->
          result = case get_in(data, [source, table_name, :rows, row_name]) do
            nil -> data
            _ -> put_in(data, [source, table_name, :rows, row_name, :data], Map.merge(get_in(data, [source, table_name, :rows, row_name, :data]), columns))
          end
        end
      end
    end
  end
  defp override(data, _opts), do: data

  defp condition_primary_key(data, path) do
    table_path = path |> Enum.take(2)
    model = get_in(data, table_path ++ [:model])
    case model.__schema__(:primary_key) do
      [primary_key] -> generate_key_value(data, path, primary_key)
      [] -> data
    end
  end

  defp generate_key_value(data, path, key) do
    table_path = path |> Enum.take(2)
    model = get_in(data, table_path ++ [:model])
    key_path = path ++ [:data, key]
    case get_in(data, key_path) |> is_nil() do
      true ->
        key_type = model.__schema__(:type, key)
        name = Enum.join(key_path, "-")

        value = case key_type do
          :id -> generate_id_key_value(name)
          :binary_id -> generate_binary_id_key_value(name)
        end

        put_in(data, key_path, value)
      false -> data
    end
  end

  defp generate_id_key_value(name) do
    :zlib.crc32(:zlib.open, name)
    |> rem(@max_id)
  end

  defp generate_binary_id_key_value(name) do
    UUID.uuid5(:oid, name)
  end

  defp condition_associations(data, path) do
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

  defp condition_function_calls(data, path) do
    Enum.reduce get_in(data, path ++ [:data]) |> Map.keys(), data, fn(column, data) ->
      value = get_in(data, path ++ [:data, column])
      |> Code.eval_quoted
      |> elem(0)
      put_in(data, path ++ [:data, column], value)
    end
  end

  defp condition_inheritance(data, path) do
    if get_in(data, path) |> Map.has_key?(:inherits) do
      put_in(data, path ++ [:data],
        Map.merge(inherits_data(data, path, get_in(data, path ++ [:inherits])), get_in(data, path ++ [:data])))
    else
      data
    end
  end

  defp inherits_data(data, path, {{:., _, [{other_table_name, _, _}, other_row_name]}, _, _}) do
    path =
      path
      |> List.replace_at(1, other_table_name)
      |> List.replace_at(3, other_row_name)
      |> List.insert_at(-1, :data)

    get_in(data, path) |> escape_values
  end

  defp inherits_data(data, path, {other_row_name, _, _}) do
    path =
      path
      |> List.replace_at(3, other_row_name)
      |> List.insert_at(-1, :data)

    get_in(data, path) |> escape_values
  end

  defp escape_values(map) do
    Enum.into map, %{}, fn({key, value}) -> {key, Macro.escape(value)} end
  end
end
