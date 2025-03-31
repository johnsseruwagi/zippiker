defmodule Zippiker.Preparations.LimitTo5 do
  use Ash.Resource.Preparation

  require Ash.Query

  @impl true
  def prepare(query, _opts, _context) do
    Ash.Query.limit(query, 5)
  end
end
