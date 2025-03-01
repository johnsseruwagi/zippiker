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

    test "User can edit category from the UI", %{conn: conn} do
      category = get_category()
      user = create_user()

      {:ok, view, html} =
        conn
        |> login(user)
        |> live(~p"/categories/#{category.id}")

      # Confirm category is rendered successfully
      assert html =~ category.name
      assert html =~ category.description

      # Confirm that we can see the form for editing the category
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ "submit"

      # Confirm that we can edit an existing category
      attributes = %{
        name: "#{category.name} updated",
        description: "#{category.description} updated."
      }
      # Confirm that the category form can be validated
      assert view
             |> form("#category-form-#{category.id}", form: %{name: ""})
             |> render_change() =~ "required"

      assert view
             |> form("#category-form-#{category.id}", form: attributes)
             |> render_submit()
             |> follow_redirect(conn, "/categories")

      # Confirm that changes were saved in the database
      require Ash.Query

      assert Zippiker.KnowledgeBase.Category
             |> Ash.Query.filter(name == ^attributes.name)
             |> Ash.Query.filter(description == ^attributes.description)
             |> Ash.exists?()
    end

    test "User can edit an existing category", %{conn: conn} do

      category = get_category()
      user = create_user()

      {:ok, view, _html} =
        conn
        |> login(user)
        |> live(~p"/categories")

      # Confirm that we can click the edit button
      assert view
             |> element("#edit-button-#{category.id}")
             |> render_click()
             |> follow_redirect(conn, ~p"/categories/#{category.id}")
    end

    test "User can go to the new category form page from the list", %{conn: conn} do
      user = create_user()
      {:ok, view, _html} =
        conn
        |> login(user)
        |> live(~p"/categories")

      assert view
      |> element("#create-category-button")
      |> render_click()
      |> follow_redirect(conn, ~p"/categories/create")
    end

    test "User should be able to delete an existing category", %{conn: conn} do
      category = get_category()
      user = create_user()

      {:ok, view, html} =
        conn
        |> login(user)
        |> live(~p"/categories")

      # Confirm category exists on the page
      assert html =~ category.name

      # Attempt to delete
      view
      |> element("#delete-button-#{category.id}")
      |> render_click()

      # Confirm category is destroyed
      require Ash.Query

      refute Zippiker.KnowledgeBase.Category
             |> Ash.Query.filter(id == ^category.id)
             |> Ash.exists?()
    end
  end
end