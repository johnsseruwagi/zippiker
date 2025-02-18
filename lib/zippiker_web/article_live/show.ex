defmodule ZippikerWeb.ArticleLive.Show do
  use ZippikerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Article {@article.id}
      <:subtitle>This is a article record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/articles/#{@article}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit article</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@article.id}</:item>
    </.list>

    <.back navigate={~p"/articles"}>Back to articles</.back>

    <.modal
      :if={@live_action == :edit}
      id="article-modal"
      show
      on_cancel={JS.patch(~p"/articles/#{@article}")}
    >
      <.live_component
        module={ZippikerWeb.ArticleLive.FormComponent}
        id={@article.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        article={@article}
        patch={~p"/articles/#{@article}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :article,
       Ash.get!(Zippiker.KnowledgeBase.Article, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Article"
  defp page_title(:edit), do: "Edit Article"
end
