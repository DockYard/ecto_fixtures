defmodule EctoFixtures.Reloader do
  def process(data, opts, acc, context \\ :default) do
    Enum.reduce(data, %{}, fn({record_name, record}, records) ->
      repos = Map.get(acc[record_name], :repos, [])
      repo = case Keyword.fetch(repos, context) do
        :error -> Keyword.get(repos, :default)
        {:ok, repo} -> repo
      end

      record = reload_record(record, repo, reload?(record_name, opts))

      Map.put(records, record_name, record)
    end)
  end

  def reload_record(record, _repo, false), do: record
  def reload_record(record, repo, true) do
    struct = record.__struct__
    [primary_key] = struct.__schema__(:primary_key)
    repo.get(struct, Map.get(record, primary_key))
  end

  def reload?(_record_name, nil), do: false
  def reload?(_record_name, false), do: false
  def reload?(_record_name, true), do: true
  def reload?(_record_name, []), do: true
  def reload?(record_name, opts) do
    case Keyword.fetch(opts, :only) do
      {:ok, only} ->
        case Keyword.fetch(opts, :except) do
          {:ok, except} ->
            Enum.member?(only -- except, record_name)
          :error ->
            Enum.member?(only, record_name)
        end
      :error ->
        case Keyword.fetch(opts, :except) do
          {:ok, except} ->
            !Enum.member?(except, record_name)
          :error -> true
        end
    end
  end
end
