defmodule ZippikerWeb.ArticleLive.Index do
  use ZippikerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Articles
      <:actions>
        <.link patch={~p"/articles/new"}>
          <.button>New Article</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="articles"
      rows={@streams.articles}
      row_click={fn {_id, article} -> JS.navigate(~p"/articles/#{article}") end}
    >
      <:col :let={{_title, article}} label="Title">{article.title}</:col>
      <:col :let={{_content, article}} label="Content">{article.content}</:col>

      <:action :let={{_id, article}}>
        <div class="sr-only">
          <.link navigate={~p"/articles/#{article}"}>Show</.link>
        </div>

        <.link patch={~p"/articles/#{article}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, article}}>
        <.link
          phx-click={JS.push("delete", value: %{id: article.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="article-modal"
      show
      on_cancel={JS.patch(~p"/articles")}
    >
      <.live_component
        module={ZippikerWeb.ArticleLive.FormComponent}
        id={(@article && @article.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        article={@article}
        patch={~p"/articles"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: ZippikerWeb.Endpoint.subscribe("articles")

    {:ok,
     socket
     |> stream(
       :articles,
       Ash.read!(Zippiker.KnowledgeBase.Article, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Article")
    |> assign(
      :article,
      Ash.get!(Zippiker.KnowledgeBase.Article, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Article")
    |> assign(:article, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Articles")
    |> assign(:article, nil)
  end

  @impl true
  def handle_info({ZippikerWeb.ArticleLive.FormComponent, {:saved, article}}, socket) do
    {:noreply, stream_insert(socket, :articles, article)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: "articles"}, socket) do
    socket
    |> stream(
      :articles,
      Ash.read!(Zippiker.KnowledgeBase.Article, actor: socket.assigns[:current_user])
    )
    |> noreply()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    article = Ash.get!(Zippiker.KnowledgeBase.Article, id, actor: socket.assigns.current_user)
    Ash.destroy!(article, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :articles, article)}
  end
end
