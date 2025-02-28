defmodule Zippiker.Preparations.MostRecent do
  use Ash.Resource.Preparation
  require Ash.Query

  def prepare(query, _opts, _context) do
    # 1. Prepare to limit results to 5 records
    # 2. Prepare to sort results by their inserted at date
    # 3. Prepare preparation to filter categories created this month only
    query
    |> Ash.Query.limit(5)
    |> Ash.Query.sort(inserted_at: :desc)
    |> Ash.Query.filter(inserted_at >= ^Date.beginning_of_month(Date.utc_today()))
  end
end
