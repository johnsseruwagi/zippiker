defmodule ZippikerWeb.Accounts.Groups.GroupsLive do
  use ZippikerWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex justify-between">
      <.header class="mt-4">
        <.icon name="hero-user-group-solid" /> {gettext("User Access Groups")}
        <:subtitle>
          {gettext("Create, update and manage user access groups and their permissions")}
        </:subtitle>
      </.header>
      <%!-- Access Group Create form --%>
      <ZippikerWeb.Accounts.Groups.GroupForm.form
        actor={@current_user}
        id={Ash.UUIDv7.generate()} />
    </div>
    <%!-- Table groups --%>
    <.table id="groups" rows={@groups}>
      <:col :let={group} label={gettext("Name")}>{group.name}</:col>
      <:col :let={group} label={gettext("Description")}>{group.description}</:col>
      <:action :let={group}>
        <div class="space-x-6">
          <.link
            id={"edit-access-group-#{group.id}"}
            phx-click={show_modal("access-group-form-modal#{group.id}")}
            class="font-semibold leading-6 text-zinc-900 hover:text-zinc-700 hover:underline"
          >
            <.icon name="hero-pencil-solid" class="h-4 w-4" />
            {gettext("Edit")}
          </.link>

          <.link
            id={"access-group-permissions-#{group.id}"}
            navigate={~p"/accounts/groups/#{group.id}/permissions"}
            class="font-semibold leading-6 text-zinc-900 hover:text-zinc-700 hover:underline"
          >
            <.icon name="hero-shield-check" class="h-4 w-4" />
            {gettext("Permissions")}
          </.link>
        </div>
      </:action>
    </.table>

    <%!-- Modals for group editing --%>
    <ZippikerWeb.Accounts.Groups.GroupForm.form
      :for={group <- @groups}
      actor={@current_user}
      group_id={group.id}
      show_button={false}
      id={group.id}
    />
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> maybe_subscribe()
    |> assign_groups()
    |> ok()
  end

  def handle_info(_message, socket) do
    socket
    |> assign_groups()
    |> noreply()
  end

  @impl true
  def handle_info({:put_flash, type, message }, socket) do
    socket
    |> put_flash(type, message)
    |> noreply()
  end

  # Subscribe connected users to the "group" topic for real-time
  # notifications when changes happen on access group
  defp maybe_subscribe(socket) do
    if connected?(socket), do: ZippikerWeb.Endpoint.subscribe("groups")

    socket
  end

  defp assign_groups(%{assigns: %{current_user: current_user}} = socket) do
    socket |> assign(:groups, get_groups(current_user))
  end

  defp get_groups(current_user) do
    Zippiker.Accounts.Group
    |> Ash.read!(actor: current_user)
  end
end