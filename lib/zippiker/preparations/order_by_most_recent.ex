defmodule Zippiker.Preparations.OrderByMostRecent do
  use Ash.Resource.Preparation

  require Ash.Query

  @impl true
  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}

      else
      {:error, "attribute must be an atom!"}
    end
  end

  @impl true
  def prepare(query, opts, _context) do
    attribute = opts[:attribute]
    query
    |> Ash.Query.sort([{attribute :desc}])
  end
end
