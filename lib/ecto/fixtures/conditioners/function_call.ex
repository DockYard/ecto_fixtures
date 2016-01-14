defmodule EctoFixtures.Conditioners.FunctionCall do
  def process(data, path) do
    Enum.reduce get_in(data, path ++ [:data]), data, fn({column, value}, data) ->
      case value do
        {_, _, _} ->
          value =
            value
            |> Code.eval_quoted
            |> elem(0)
          put_in(data, path ++ [:data, column], value)
        _ ->
          data
      end
    end
  end
end
