defmodule ZippikerWeb.KnowledgeBase.CategoriesLiveTest do
  use Gettext, backend: ZippikerWeb.Gettext
  use ZippikerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import AuthCase
  import CategoryCase

  describe "Categories live tests" do
    test "Guest can not access /categories", %{conn: conn} do
      assert conn
             |> live(~p"/categories")
               #    Guests are redirected to the login page
             |> follow_redirect(conn, "/sign-in")
    end

    test "User can access /categories", %{conn: conn} do

      user = create_user()
      categories = get_categories()

      {:ok, _view, html} =
      conn
      |> login(user)
      |> live(~p"/categories")

      #Confirm that we can see the Categories title
      assert html =~ gettext("Categories")

      # Confirm that every created category is listed
      for category <- categories do
        assert html =~ category.name
      end

    end
  end
end