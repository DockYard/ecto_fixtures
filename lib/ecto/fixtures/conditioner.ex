defmodule EctoFixtures.Conditioner do
  @max_id trunc(:math.pow(2, 30) - 1)

  def condition(data) do
    Map.keys(data)
    |> Enum.reduce data, fn(table_name, data) ->
      _condition_table(data, table_name)
    end
  end

  defp _condition_table(data, table_name) do
    Map.keys(data[table_name].rows)
    |> Enum.reduce data, fn(row_name, data) ->
      _condition_row(data, table_name, row_name)
    end
  end

  defp _condition_row(data, table_name, row_name) do
    data
    |> _condition_inheritance(table_name, row_name)
    |> _condition_primary_key(table_name, row_name)
    |> _condition_associations(table_name, row_name)
    |> _condition_function_calls(table_name, row_name)
  end

  defp _condition_primary_key(data, table_name, row_name) do
    model = data[table_name].model
    [primary_key] = model.__schema__(:primary_key)
    _generate_key_value(data, table_name, row_name, primary_key)
  end

  defp _generate_key_value(data, table_name, row_name, key) do
    model = data[table_name].model
    case is_nil(data[table_name].rows[row_name].data[key]) do
      true ->
        key_type = model.__schema__(:type, key)
        name = Enum.join([table_name, row_name, key], "-")

        value = case key_type do
          :id -> _generate_id_key_value(name)
          :binary_id -> _generate_binary_id_key_value(name)
        end

        put_in(data[table_name].rows[row_name].data[key], value)
      false -> data
    end
  end

  defp _generate_id_key_value(name) do
    :zlib.crc32(:zlib.open, name)
    |> rem(@max_id)
  end

  defp _generate_binary_id_key_value(name) do
    UUID.uuid5(:oid, name)
  end

  defp _key_from_array(keys), do: Enum.join(keys, "-")

  defp _condition_associations(data, table_name, row_name) do
    model = data[table_name].model
    columns = data[table_name].rows[row_name].data

    model.__schema__(:associations)
    |> Enum.reduce data, fn(association_name, data) ->
      if data[table_name][:rows][row_name].data[association_name] do
        case model.__schema__(:association, association_name) do
          %Ecto.Association.Has{} = association ->
            _has_association(data, table_name, row_name, association)
          %Ecto.Association.BelongsTo{} = association ->
            _belongs_to_association(data, table_name, row_name, association)
        end
      else
        data
      end
    end
  end

  defp _has_association(data, table_name, row_name, %{cardinality: :one} = association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    association_path = _get_path(data[table_name].rows[row_name].data[field])
    data = _generate_key_value(data, table_name, row_name, owner_key)
    owner_key_value = data[table_name].rows[row_name].data[owner_key]
    data = put_in(data, association_path ++ [related_key], owner_key_value)
    put_in(data[table_name].rows[row_name].data, Map.delete(data[table_name].rows[row_name].data, field))
  end

  defp _has_association(data, table_name, row_name, %{cardinality: :many} = association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    data = Enum.reduce data[table_name].rows[row_name].data[field], data, fn(association_expr, data) ->
      association_path = _get_path(association_expr)
      data = _generate_key_value(data, table_name, row_name, owner_key)
      owner_key_value = data[table_name].rows[row_name].data[owner_key]
      put_in(data, association_path ++ [related_key], owner_key_value)
    end
    put_in(data[table_name].rows[row_name].data, Map.delete(data[table_name].rows[row_name].data, field))
  end

  defp _belongs_to_association(data, table_name, row_name, association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    [related_table_name, _, related_row_name, _] = _get_path(data[table_name].rows[row_name].data[field])
    data = _generate_key_value(data, related_table_name, related_row_name, related_key)
    related_key_value = data[related_table_name].rows[related_row_name].data[related_key]
    data = put_in(data, [table_name, :rows, row_name, :data, owner_key], related_key_value)
    put_in(data[table_name].rows[row_name].data, Map.delete(data[table_name].rows[row_name].data, field))
  end

  defp _get_path({{:., _, [{table_name, _, _}, row_name]}, _, _}) do
    [table_name, :rows, row_name, :data]
  end

  def _condition_function_calls(data, table_name, row_name) do
    Enum.reduce Map.keys(data[table_name].rows[row_name].data), data, fn(column, data) ->
      case data[table_name].rows[row_name].data[column] do
        {{:., _, _}, _, _} = expr ->
          put_in data[table_name].rows[row_name].data[column], elem(Code.eval_quoted(expr), 0)
        _ ->
          data
      end
    end
  end

  def _condition_inheritance(data, table_name, row_name) do
    if Map.has_key?(data[table_name].rows[row_name], :inherits) do
      put_in data[table_name].rows[row_name].data,
        Map.merge(_inherits_data(data, table_name, data[table_name].rows[row_name].inherits), data[table_name].rows[row_name].data)
    else
      data
    end
  end

  def _inherits_data(data, table_name, {{:., _, [{other_table_name, _, _}, other_row_name]}, _, _}) do
    data[other_table_name].rows[other_row_name].data
  end

  def _inherits_data(data, table_name, {other_row_name, _, _}) do
    data[table_name].rows[other_row_name].data
  end
end
