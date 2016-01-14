defmodule EctoFixtures.Conditioners.Associations do
  import EctoFixtures.Conditioners.PrimaryKey, only: [generate_key_value: 3]

  def process(data, path) do
    table_path = path |> Enum.take(2)
    model = get_in(data, table_path ++ [:model])

    Enum.reduce model.__schema__(:associations), data, fn(association_name, data) ->
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
    { data, association_path } = get_path(data, path, get_in(data, path ++ [:data, field]))
    data = generate_key_value(data, path, owner_key)
    owner_key_value = get_in(data, path ++ [:data, owner_key])
    put_in(data, association_path ++ [:data, related_key], owner_key_value)
    |> put_in(path ++ [:data], Map.delete(get_in(data, path ++ [:data]), field))
    |> EctoFixtures.Conditioners.DAG.add_vertex(association_path, get_in(data, [:__DAG__]))
    |> EctoFixtures.Conditioners.DAG.add_edge(path, association_path)
  end

  defp has_association(data, path, %{cardinality: :many} = association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    data = Enum.reduce get_in(data, path ++ [:data, field]), data, fn(association_expr, data) ->
      { data, association_path } = get_path(data, path, association_expr)
      data = generate_key_value(data, path, owner_key)
      owner_key_value = get_in(data, path ++ [:data, owner_key])
      put_in(data, association_path ++ [:data, related_key], owner_key_value)
      |> EctoFixtures.Conditioners.DAG.add_vertex(association_path, get_in(data, [:__DAG__]))
      |> EctoFixtures.Conditioners.DAG.add_edge(path, association_path)
    end
    put_in(data, path ++ [:data], Map.delete(get_in(data, path ++ [:data]), field))
  end

  defp belongs_to_association(data, path, association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    {data, association_path} = get_path(data, path, get_in(data, path ++ [:data, field]))

    data = generate_key_value(data, association_path, related_key)
    related_key_value = get_in(data, association_path ++ [:data, related_key])
    data = put_in(data, path ++ [:data, owner_key], related_key_value)
    put_in(data, path ++ [:data], Map.delete(get_in(data, path ++ [:data]), field))
    |> EctoFixtures.Conditioners.DAG.add_vertex(association_path, get_in(data, [:__DAG__]))
    |> EctoFixtures.Conditioners.DAG.add_edge(association_path, path)
  end

  defp get_path(data, path, {{:., _, [{{:., _, [{:fixtures, _, [file_path]}, other_table_name]}, _, _}, other_row_name]}, _, _}) do
    other_source = "test/fixtures/#{file_path}.exs"
    other_source_atom = String.to_atom(other_source)
    [source, _table_name, :rows, _row_name] = path

    other_source_data = EctoFixtures.read(other_source)
    |> EctoFixtures.parse
    |> EctoFixtures.Conditioner.process(source: source)

    other_source_info = get_in(other_source_data, [other_source_atom, other_table_name])

    other_data = %{
      other_source_atom => %{
        other_table_name => %{
          model: get_in(other_source_data, [other_source_atom, other_table_name, :model]),
          repo: get_in(other_source_data, [other_source_atom, other_table_name, :repo]),
          rows: %{
            other_row_name => get_in(other_source_data, [other_source_atom, other_table_name, :rows, other_row_name])
          }
        }
      }
    }

    { EctoFixtures.Utils.deep_merge(data, other_data),
      [other_source_atom, other_table_name, :rows, other_row_name] }
  end

  defp get_path(data, path, {{:., _, [{other_table_name, _, _}, other_row_name]}, _, _}) do
    source = List.first(path)
    { data, [source, other_table_name, :rows, other_row_name] }
  end
end
