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
          %Ecto.Association.HasThrough{} = association ->
            has_through_association(data, path, association)
          %Ecto.Association.BelongsTo{} = association ->
            belongs_to_association(data, path, association)
        end
      else
        data
      end
    end
  end

  defp has_association(data, path, %{cardinality: :one} = association) do
    data = put_in(data, path ++ [:data, association.field], get_in(data, path ++ [:data, association.field]) |> List.wrap)
    has_association(data, path, struct(association, %{cardinality: :many}))
  end

  defp has_association(data, path, %{cardinality: :many} = association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    Enum.reduce(get_in(data, path ++ [:data, field]), data, fn(association_expr, data) ->
      { data, association_path } = get_path(data, path, association_expr)
      data = generate_key_value(data, path, owner_key)
      owner_key_value = get_in(data, path ++ [:data, owner_key])
      put_in(data, association_path ++ [:data, related_key], owner_key_value)
      |> EctoFixtures.Conditioners.DAG.add_vertex(association_path, get_in(data, [:__DAG__]))
      |> EctoFixtures.Conditioners.DAG.add_edge(path, association_path)
    end)
    |> delete_in(path ++ [:data, field])
  end

  defp has_through_association(data, path, %{cardinality: :one} = association) do
    data = put_in(data, path ++ [:data, association.field], get_in(data, path ++ [:data, association.field]) |> List.wrap)
    has_through_association(data, path, struct(association, %{cardinality: :many}))
  end

  defp has_through_association(data, [source, table_name, :rows, _row_name] = path, %{cardinality: :many} = association) do
    %{owner: owner, field: field, through: [through_association_name, inverse_association_name]} = association

    through_association = owner.__schema__(:association, through_association_name)
    %{owner_key: through_owner_key, related_key: through_related_key, related: through_related} = through_association

    inverse_association = through_related.__schema__(:association, inverse_association_name)
    %{field: inverse_field, owner_key: inverse_owner_key, related_key: inverse_related_key} = inverse_association

    Enum.reduce(get_in(data, path ++ [:data, field]), data, fn(association_expr, data) ->

      { data, inverse_association_path } = get_path(data, path, association_expr)

      data = generate_key_value(data, inverse_association_path, inverse_related_key)

      through_schema_source =
        through_related.__schema__(:source)
        |> String.to_atom()

      through_row_name =
        Enum.join(path, "-") <> ":" <> Enum.join(inverse_association_path, "-")
        |> String.to_atom

      through_data = %{
        source => %{
          through_schema_source => %{
            model: through_related,
            repo: get_in(data, [source, table_name, :repo]),
            rows: %{
              through_row_name => %{
                data: %{
                  inverse_owner_key => get_in(data, inverse_association_path ++ [:data, inverse_related_key]),
                  through_related_key => get_in(data, path ++ [:data, through_owner_key])
                }
              }
            }
          }
        }
      }

      through_association_path = [source, through_schema_source, :rows, through_row_name]

      EctoFixtures.Utils.deep_merge(data, through_data)
      |> delete_in(inverse_association_path ++ [:data, inverse_field])
      |> EctoFixtures.Conditioners.DAG.add_vertex(inverse_association_path, get_in(data, [:__DAG__]))
      |> EctoFixtures.Conditioners.DAG.add_vertex(through_association_path, get_in(data, [:__DAG__]))
      |> EctoFixtures.Conditioners.DAG.add_edge(path, through_association_path)
      |> EctoFixtures.Conditioners.DAG.add_edge(inverse_association_path, through_association_path)
    end)
    |> delete_in(path ++ [:data, field])
  end

  defp belongs_to_association(data, path, association) do
    %{field: field, owner_key: owner_key, related_key: related_key} = association
    {data, association_path} = get_path(data, path, get_in(data, path ++ [:data, field]))

    data = generate_key_value(data, association_path, related_key)
    related_key_value = get_in(data, association_path ++ [:data, related_key])
    data
    |> put_in(path ++ [:data, owner_key], related_key_value)
    |> delete_in(path ++ [:data, field])
    |> EctoFixtures.Conditioners.DAG.add_vertex(association_path, get_in(data, [:__DAG__]))
    |> EctoFixtures.Conditioners.DAG.add_edge(association_path, path)
  end

  defp get_path(data, path, {{:., _, [{{:., _, [{:fixtures, _, [file_path]}, inverse_table_name]}, _, _}, inverse_row_name]}, _, _}) do
    inverse_source = "test/fixtures/#{file_path}.exs"
    inverse_source_atom = String.to_atom(inverse_source)
    [source, _table_name, :rows, _row_name] = path

    inverse_source_data =
      inverse_source
      |> EctoFixtures.read()
      |> EctoFixtures.parse()
      |> Map.put(:__DAG__, get_in(data, [:__DAG__]))
      |> EctoFixtures.Conditioner.process(source: source)

    inverse_data = %{
      inverse_source_atom => %{
        inverse_table_name => %{
          model: get_in(inverse_source_data, [inverse_source_atom, inverse_table_name, :model]),
          repo: get_in(inverse_source_data, [inverse_source_atom, inverse_table_name, :repo]),
          rows: %{
            inverse_row_name => get_in(inverse_source_data, [inverse_source_atom, inverse_table_name, :rows, inverse_row_name])
          }
        }
      }
    }

    { EctoFixtures.Utils.deep_merge(data, inverse_data),
      [inverse_source_atom, inverse_table_name, :rows, inverse_row_name] }
  end

  defp get_path(data, path, {{:., _, [{inverse_table_name, _, _}, inverse_row_name]}, _, _}) do
    source = List.first(path)
    { data, [source, inverse_table_name, :rows, inverse_row_name] }
  end

  defp delete_in(data, path) do
    {path, [target]} = Enum.split(path, length(path) - 1)
    put_in(data, path, Map.delete(get_in(data, path), target))
  end
end
