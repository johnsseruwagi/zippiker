defmodule ZippikerWeb.CategoriesLive do
  use ZippikerWeb, :live_view
  alias Zippiker.KnowledgeBase.Category

  def mount(_params, _session, socket) do
    # if the user is connected then subscribe to all events/ topic
    # with categories event
    if connected?(socket) do
      ZippikerWeb.Endpoint.subscribe("categories")
    end

    socket
    |> assign_categories()
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <%!-- New Category Button --%>
    <.header>
    <%!-- List category records --%>
    {gettext("Categories")}

    <:actions>
    <.link patch={~p"/categories/create"}>
      <.button>New Category</.button>
    </.link>
    </:actions>
    </.header>


    <.table id="knowledge-base-categories" rows={@categories}>
      <:col :let={row} label={gettext("Name")}>{row.name}</:col>
      <:col :let={row} label={gettext("Description")}>{row.description}</:col>
      <:action :let={row}>


        <%!-- Edit Category button --%>
        <.button
          id={"edit-button-#{row.id}"}
          phx-click={JS.navigate(~p"/categories/#{row.id}")}
          class="bg-white
           text-zinc-300
           hover:bg-white
           hover:text-zinc-600
           hover:underline"
        >
          Edit
        </.button>


        <%!-- Delete Category Button --%>
        <.button
          id={"delete-button-#{row.id}"}
          phx-click={"delete-#{row.id}"}
          class="bg-white
          text-zinc-300
          hover:bg-white
          hover:text-zinc-600"
        >
          Delete
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

  @doc """
  Function that responds when an event with topic "categories" is detected.
  It does two things
  1. It pattern matches events with topic "categories" only
  2. It refreshes categories from DB via assign_categories
  """
  def handle_info(%Phoenix.Socket.Broadcast{topic: "categories"}, socket) do
    socket
    |> assign_categories()
    |> noreply()
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