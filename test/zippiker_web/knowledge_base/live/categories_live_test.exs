defmodule ZippikerWeb.KnowledgeBase.CategoriesLiveTest do
  use Gettext, backend: ZippikerWeb.Gettext
  use ZippikerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  describe "Categories live tests" do
    test "Guest can not access /categories", %{conn: conn} do
      assert conn
             |> live(~p"/categories")
               #    Guests are redirected to the login page
             |> follow_redirect(conn, "/sign-in")
    end

    test "User can access /categories", %{conn: conn} do
      # 1. Create user
      user =
      Zippiker.Accounts.User
      |> Ash.Seed.seed!(%{email: "nath.tester@example.com"})

      # 2. Generate authentication token
      {:ok, token, _claims} =
      AshAuthentication.Jwt.token_for_user(user, %{}, domain: Zippiker.Accounts)

      #. Login the user
      authenticated_conn =
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Plug.Conn.put_session(:user_token, token)

      # 3. Create categories to test with
      categories_attrs = [
          %{
          name: "Account and Login",
          slug: "account-login",
          description: "Help with account creation, login issues and profile management"
          },
          %{
          name: "Billing and Payments",
          slug: "billing-payments",
          description: "Assistance with invoices, subscription plans, and payment issues"
          }
      ]

      categories =
      Zippiker.KnowledgeBase.Category
      |> Ash.Seed.seed!(categories_attrs)

      # Attempt to visit protected page with an authenticated connection
      {:ok, _view, html} =
      authenticated_conn
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