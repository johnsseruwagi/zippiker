defmodule ZippikerWeb.CategoriesLive do
  use ZippikerWeb, :live_view
  alias Zippiker.KnowledgeBase.Category

  def mount(_params, _session, socket) do
    socket
    |> assign_categories()
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <%!-- New Category Button --%>
    <.button id="create-category-button" phx-click={JS.navigate(~p"/categories/create")}>
      <.icon name="hero-plus-solid" />

    </.button>


    <%!-- List category records --%>
    <h1>{gettext("Categories")}</h1>


    <.table id="knowledge-base-categories" rows={@categories}>
      <:col :let={row} label={gettext("Name")}>{row.name}</:col>
      <:col :let={row} label={gettext("Description")}>{row.description}</:col>
      <:action :let={row}>


        <%!-- Edit Category button --%>
        <.button
          id={"edit-button-#{row.id}"}
          phx-click={JS.navigate(~p"/categories/#{row.id}")}
          class="bg-white
           text-zinc-500
           hover:bg-white
           hover:text-zinc-900
           hover:underline"
        >
          <.icon name="hero-pencil-solid" />
        </.button>


        <%!-- Delete Category Button --%>
        <.button
          id={"delete-button-#{row.id}"}
          phx-click={"delete-#{row.id}"}
          class="bg-white
          text-zinc-500
          hover:bg-white
          hover:text-zinc-900"
        >
          <.icon name="hero-trash-solid" />
        </.button>
      </:action>
    </.table>
    """
  end

  # Responds when a user clicks on trash button
  def handle_event("delete-" <> category_id, _params, socket) do
    case destroy_record(category_id) do
      :ok ->
        socket
        |> put_flash(:info, "Category deleted successfully")
        |> noreply()

      {:error, _error} ->

        socket
        |> put_flash(:error, "Unable to delete category")
        |> noreply()
    end
  end

  defp assign_categories(socket) do
    {:ok, categories} =
      Category
      |> Ash.read()

    assign(socket, :categories, categories)
  end

  defp destroy_record(category_id) do
    Category
    |> Ash.get!(category_id)
    |> Ash.destroy()
  end
end