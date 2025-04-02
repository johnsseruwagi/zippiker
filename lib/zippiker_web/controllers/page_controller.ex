defmodule ZippikerWeb.PageController do
  use ZippikerWeb, :controller

  alias Zippiker.KnowledgeBase.Category

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    # TODO: Configure default tenant. For now, we are picking the first available tenant
    categories =
      if team = Ash.read_first!(Zippiker.Accounts.Team) do
        Ash.read!(Category, load: :article_count, tenant: team.domain)
      else
        []
      end


    render(conn, :home, layout: false, categories: categories)
  end
end
