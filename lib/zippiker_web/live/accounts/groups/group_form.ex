defmodule ZippikerWeb.Accounts.Groups.GroupForm do
  use ZippikerWeb, :live_component

  alias AshPhoenix.Form


  def render(assigns) do
    ~H"""
    <div id={"access-group-#{@id}"} class="mt-4">

        <.header class="mt-4">
          <.icon name="hero-user-group" />
          <span >{@title}</span>
          <:subtitle>
            {@subtitle}
          </:subtitle>

        </.header>
        <.simple_form
          for={@form}
          phx-change="validate"
          phx-submit="save"
          id={"access-group-form"}
          phx-target={@myself}
        >
          <.input
            field={@form[:name]}
            id={"access-group-name#{@id}"}
            label={gettext("Access Group Name")}
          />
          <.input
            field={@form[:description]}
            id={"access-group-description#{@id}"}
            type="textarea"
            label={gettext("Description")}
          />
          <:actions>
            <.button class="w-full" phx-disable-with={gettext("Saving...")}>
              {gettext("Submit")}
            </.button>
          </:actions>
        </.simple_form>

    </div>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_form()
    |> ok()
  end

  def handle_event("validate", %{"form" => group_params}, %{assigns: %{form: form}} = socket) do
    socket
    |> assign(:form, Form.validate(form, group_params))
    |> noreply()
  end

  def handle_event("save", %{"form" => group_params}, %{assigns: %{form: form}}=socket) do
    case Form.submit(form, params: group_params) do
      {:ok, group} ->
        notify_parent({:saved, group})
        socket
        |> put_flash(:info, gettext("Access Group Submitted."))
        |> push_patch(to: socket.assigns.patch)
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end


  defp assign_form(%{assigns: assigns} = socket) do
    socket |> assign(:form, get_form(assigns))
  end

  defp get_form(%{group: nil} = assigns) do
    Zippiker.Accounts.Group
    |> Form.for_create(:create, as: "group", actor: assigns.actor)
    |> to_form()
  end

  defp get_form(%{group: group} = assigns) do
     Form.for_update(group, :update,as: "group", actor: assigns.actor)
    |> to_form()
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end