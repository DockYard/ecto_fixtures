defmodule EctoFixtures.Dag.Vertex do
  @moduledoc """
  Vertex struct for `EctoFixtures.Dag`
  """

  @type t :: %__MODULE__{label: atom, out_edges: list, in_edges: list, value: any}

  defstruct label: nil, out_edges: [], in_edges: [], value: nil
end