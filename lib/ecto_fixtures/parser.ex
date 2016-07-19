defmodule EctoFixtures.Parser do
  def process(acc, fixture_path) do
    ast =
      File.read!(fixture_path)
      |> Code.string_to_quoted!()

    {_, {acc, _}} = parse_ast(ast, fixture_path, acc)

    acc
  end

  defp parse_ast(ast, path, acc),
    do: Macro.prewalk(ast, {acc, [path: path]}, &parse_quoted(&1, &2))

  # ignore the block
  defp parse_quoted({:__block__, _, lines}, acc),
    do: {lines, acc}

  # parse module attributes
  defp parse_quoted({:@, _, [{key, _, [quoted_value]}]}, {acc, opts}) do
    {value, _} = Code.eval_quoted(quoted_value)

    value = case key do
      key when key in ~w(enum var)a ->
        Keyword.get(opts, key, [])
        |> Keyword.merge(value)
      :group ->
        Keyword.get(opts, :group, [])
        |> List.insert_at(-1, value)
      _ -> value
    end

    opts =
      opts
      |> Keyword.put(key, value)
      |> reset_opts(key)

    {nil, {acc, opts}}
  end

  # parse base module attribute
  defp parse_quoted({:@, _, [{key, _, nil}]}, {acc, opts}) do
    parse_quoted({:@, nil, [{key, nil, [true]}]}, {acc, opts})
  end

  # parse named row
  defp parse_quoted({row_name, _, quoted_columns}, {acc, opts}) do
    case Keyword.fetch(opts, :generate) do
      {:ok, 0} ->
        opts = Keyword.delete(opts, :generate)
        {nil, {acc, opts}}
      {:ok, i} ->
        generated_row_name = :"#{row_name}_#{i}"
        {nil, {acc, opts}} = parse_row({generated_row_name, nil, quoted_columns}, {acc, opts})
        opts = Keyword.put(opts, :generate, i - 1)
        parse_quoted({row_name, nil, quoted_columns}, {acc, opts})
      :error -> parse_row({row_name, nil, quoted_columns}, {acc, opts})
    end
  end

  defp parse_row({row_name, _, quoted_columns}, {acc, opts}) do
    columns =
      quoted_columns
      |> case do
        [[do: {:__block__, _, columns}]] -> columns
        [[do: nil]] -> []
        [[do: column]] -> [column]
      end
      |> Enum.into(%{}, fn
        {name, _, [{_, _, _} = value]} ->
          {value, _} = Code.eval_quoted(value, bindings(opts))
          {name, value}
        {name, _, [value]} -> {name, value}
      end)

    assert_repo(opts[:repo], opts[:path], row_name)
    assert_model(opts[:model], opts[:path], row_name)
    assert_row_name(row_name, opts[:path], acc)
    assert_group(opts[:group], opts[:path], row_name, acc)

    row = build_row(%{}, [{:columns, columns} | opts], [:model, :repo, :path, :columns, :inherits, :virtual, :serializer])

    acc =
      add_to_group(acc, opts[:group], row_name)
      |> Map.put(row_name, row)

    opts = clear_attributes(opts, [:inherits, :virtual, :generate])

    {nil, {acc, opts}}
  end

  defp assert_repo(nil, path, row_name) do
    msg = """
    No @repo defined in `#{path}` for `#{row_name}`.
    You can fix this by adding the repo module attribute to your fixture file:

        @repo MyApp.Repo

    Just make sure you set the value to the actual repo module.
    """
    raise EctoFixtures.MissingRepoError, msg
  end
  defp assert_repo(_repo, _path, _row_name), do: nil

  defp assert_model(nil, path, row_name) do
    msg = """
    No @model defined in `#{path}` for `#{row_name}`.
    You can fix this by adding the model module attribute to your fixture file:

        @model MyApp.User

    Just make sure you set the value to the actual model module.
    """
    raise EctoFixtures.MissingModelError, msg
  end
  defp assert_model(_model, _path, _row_name), do: nil

  defp assert_row_name(row_name, path, acc) do
    case Map.fetch(acc, row_name) do
      {:ok, row_acc} when is_map(row_acc) ->
        msg = """
        You are attempting to redefine `#{row_name}`.

        The fixture `#{row_name}` already exists and was defined in `#{get_in(acc, [row_name, :path])}` but
        there was an attempt to redefine it in the file `#{path}`.

        You cannot have duplicate fixture names. Each fixture name must be unique across all fixture files.
        """

        raise EctoFixtures.FixtureNameCollisionError, msg

      {:ok, grouped_rows} when is_list(grouped_rows) ->
        msg = """
        The fixture name `#{row_name}` defined in `#{path}` is conflicting with the
        group name `#{row_name}`. Please choose a different name.
        """

        raise EctoFixtures.GroupNameFixtureNameCollisionError, msg

      :error -> nil
    end
  end

  defp assert_group(nil, _path, _row_name, _acc), do: nil
  defp assert_group([], _path, _row_name, _acc), do: nil
  defp assert_group([group|groups], path, row_name, acc) do
    assert_group(group, path, row_name, acc)
    assert_group(groups, path, row_name, acc)
  end
  defp assert_group(group, path, _row_name, acc) do
    Enum.each acc, fn
      {^group, row_names} when is_list(row_names) -> nil
      {^group, fixture} when is_map(fixture) ->
        msg = """
        The group name `#{group}` defined in `#{path}` is conflicting with the
        fixture name `#{group}` defined in `#{get_in(acc, [group, :path])}`. Please choose a different name.
        """

        raise EctoFixtures.GroupNameFixtureNameCollisionError, msg
      _ -> nil
    end
  end

  defp add_to_group(acc, nil, _row_name), do: acc
  defp add_to_group(acc, [], _row_name), do: acc
  defp add_to_group(acc, [group | groups], row_name) do
    row_names = Map.get(acc, group, [])
    Map.put(acc, group, List.insert_at(row_names, -1, row_name))
    |> add_to_group(groups, row_name)
  end
  defp add_to_group(acc, group, row_name),
    do: add_to_group(acc, [group], row_name)

  defp build_row(row, _opts, []), do: row
  defp build_row(row, opts, [attribute | attributes]) do
    row = case opts[attribute] do
      nil -> row
      value ->  Map.put(row, attribute, value)
    end

    build_row(row, opts, attributes)
  end

  defp clear_attributes(opts, []), do: opts
  defp clear_attributes(opts, [attribute | attributes]) do
    Keyword.delete_first(opts, attribute)
    |> clear_attributes(attributes)
  end

  defp reset_opts(opts, :model),
    do: Keyword.delete(opts, :serializer)
        |> Keyword.delete(:group)
  defp reset_opts(opts, _), do: opts

  defp bindings(opts) do
    i = opts[:generate]
    [i: i]
    |> merge_enum(opts[:enum], i)
    |> merge_var(opts[:var])
    |> Enum.filter(fn
      {_key, nil} -> false
      {_key, _value} -> true
    end)
  end

  defp merge_var(bindings, nil), do: bindings
  defp merge_var(bindings, vars),
    do: Keyword.merge(bindings, vars)

  defp merge_enum(bindings, nil, _), do: bindings
  defp merge_enum(bindings, _, nil), do: bindings
  defp merge_enum(bindings, enums, i) do
    Enum.map(enums, fn({key, values}) ->
      idx = rem(i - 1, length(values))
      {key, Enum.fetch!(values, idx)}
    end)
    |> Keyword.merge(bindings)
  end
end
