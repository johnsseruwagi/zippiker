defmodule Zippiker.Preparations.OrderByMostRecent do
  use Ash.Resource.Preparation

  require Ash.Query

  def prepare(query, _opts, _context) do
    Ash.Query.sort(query, inserted_at: :desc)
  end
end
