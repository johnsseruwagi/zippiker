defmodule ZippikerWeb.ArticleLive.FormComponent do
  use ZippikerWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage article records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="article-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input
          field={@form[:slug]}
          type="text"
          label="Slug"
        />
        <.input field={@form[:content]} type="text" label="Content" />
          <.input
          field={@form[:views_count]}
          type="number"
          label="Views count"
        /><.input field={@form[:published]} type="checkbox" label="Published" /><.input
          field={@form[:category_id]}
          type="text"
          label="Category"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Article</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"article" => article_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, article_params))}
  end

  def handle_event("save", %{"article" => article_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: article_params) do
      {:ok, article} ->
        notify_parent({:saved, article})

        socket =
          socket
          |> put_flash(:info, "Article #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{article: article}} = socket) do
    form =
      if article do
        AshPhoenix.Form.for_update(article, :update,
          as: "article",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Zippiker.KnowledgeBase.Article, :create,
          as: "article",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
