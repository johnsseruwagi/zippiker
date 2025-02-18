defmodule ZippikerWeb.PageController do
  use ZippikerWeb, :controller

  alias Zippiker.KnowledgeBase.Category

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    category = Category |> Ash.read!(load: :article_count)

    render(conn, :home, layout: false, categories: category)
  end
end
