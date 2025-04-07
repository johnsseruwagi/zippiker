defmodule ZippikerWeb.Accounts.Groups.GroupForm do
  use ZippikerWeb, :live_component

  alias AshPhoenix.Form

  @doc """
  This a wrapper used to access this component like a static component
  in the template.

  example:
    <ZippikerWeb.Accounts.Groups.GroupForm.form
      :for={group <- @groups}
      actor={@current_user}
      group_id={group.id}
      show_button={false}
      id={group.id}
    />
  """

  attr :id, :string, required: true
  attr :actor, Zippiker.Accounts.User, required: true
  attr :group_id, :string, default: nil
  attr :show_button, :boolean, default: true, doc: "Show button to create new group"
  def form(assigns) do
    ~H"""
    <.live_component
      id={@id}
      actor={@actor}
      group_id={@group_id}
      show_button={@show_button}
      module={__MODULE__}
    />

    """
  end

  attr :id, :string, required: true
  attr :group_id, :string, default: nil
  attr :show_button, :boolean, default: true
  attr :actor, Zippiker.Accounts.User, required: true
  def render(assigns) do
    ~H"""
    <div id={"access-group-#{@group_id}"} class="mt-4" >
      <%!-- form trigger button --!%>
      <div class="flex justify-end">
        <.button
          :if={@show_button}
          phx-click={show_modal("access-group-form-modal#{@group_id}")}
          id={"access-group-modal-button#{@group_id}"}
        >
          <.icon name="hero-plus-solid" class="h-5 w-5" />
        </.button>
      </div>

      <%!-- We want this form to show-up in a modal --%>
      <.modal id={"access-group-form-modal#{@group_id}"}>
        <.header class="mt-4">
          <.icon name="hero-user-group" />
          <%!-- New Group --%>
          <span :if={is_nil(@group_id)}>{gettext("New Access Group")}</span>
          <:subtitle :if={is_nil(@group_id)}>
            {gettext("Fill below form to create a new user access group")}
          </:subtitle>

          <%!-- Existing group --%>
          <span :if={@group_id}>{@form.source.data.name}</span>
          <:subtitle :if={@group_id}>
            {gettext("Fill below form to update %{name} access group details.",
              name: @form.source.data.name
            )}
          </:subtitle>
        </.header>
        <.simple_form
          for={@form}
          phx-change="validate"
          phx-submit="save"
          id={"access-group-form#{@group_id}"}
          phx-target={@myself}
        >
          <.input
            field={@form[:name]}
            id={"access-group-name#{@id}-#{@group_id}"}
            label={gettext("Access Group Name")}
          />
          <.input
            field={@form[:description]}
            id={"access-group-description#{@id}-#{@group_id}"}
            type="textarea"
            label={gettext("Description")}
          />
          <:actions>
            <.button class="w-full" phx-disable-with={gettext("Saving...")}>
              {gettext("Submit")}
            </.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_form()
    |> ok()
  end

  def handle_event("validate", %{"form" => attrs}, %{assigns: %{form: form}} = socket) do
    socket
    |> assign(:form, Form.validate(form, attrs))
  end

  def handle_event("save", %{"form" => attrs}, %{assigns: %{form: form, group_id: group_id}} = socket) do
    case Form.submit(form, params: attrs) do
      {:ok, _group} ->
        socket
        |> put_component_flash(:info, gettext("Access Group Submitted."))
        |> cancel_modal("access-group-form-modal#{group_id}")
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  # Prevents the form from being re-created on every update
  defp assign_form(%{assigns: %{form: _form}} = socket) do
    socket
  end

  defp assign_form(%{assigns: assigns} = socket) do
    socket |> assign(:form, get_form(assigns))
  end

  # Build for the new access group
  defp get_form(%{group_id: nil} = assigns) do
    Zippiker.Accounts.Group
    |> Form.for_create(:create, actor: assigns.actor)
    |> to_form()
  end

  # Build for the existing access group
  defp get_form(%{group_id: group_id} = assigns) do
    Zippiker.Accounts.Group
    |> Ash.get!(group_id, actor: assigns.actor)
    |> Form.for_update(:update, actor: assigns.actor)
    |> to_form()
  end
end