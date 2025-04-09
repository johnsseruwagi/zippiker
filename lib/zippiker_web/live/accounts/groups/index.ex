defmodule ZippikerWeb.Accounts.Groups.Index do
  use ZippikerWeb, :live_view


  def render(assigns) do
    ~H"""
    <div class="flex justify-between">
      <.header class="mt-4">
        <.icon name="hero-user-group-solid" /> {@page_title}
        <:subtitle>
          {@page_subtitle}
        </:subtitle>
        <:actions>
          <.link patch={~p"/accounts/groups/new"}>
            <.button
              id={"access-group-modal-button"}
            >
              <.icon name="hero-plus-solid" class="h-5 w-5" />
            </.button>
          </.link>
        </:actions>
      </.header>

    </div>
    <%!-- Table groups --%>
    <.table
    id="groups"
    rows={@streams.groups}
    >
      <:col :let={{_name, group}} label={gettext("Name")}>{group.name}</:col>
      <:col :let={{_description, group}} label={gettext("Description")}>{group.description}</:col>
      <:action :let={{_id, group}}>
        <div class="space-x-6">
          <.link
            id={"edit-access-group-#{group.id}"}
            patch={~p"/accounts/groups/#{group}/edit"}
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

    <.modal
      :if={@live_action in [:new, :edit]}
      id="access-group-modal"
      show
      on_cancel={JS.patch(~p"/accounts/groups")}
    >
      <.live_component
        module={ZippikerWeb.Accounts.Groups.GroupForm}
        id={(@group && @group.id) || :new}
        title={@page_title}
        subtitle={@page_subtitle}
        actor={@current_user}
        action={@live_action}
        group={@group}
        patch={~p"/accounts/groups"}
      />
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> maybe_subscribe()
    |> stream_groups()
    |> assign_new(:current_user, fn -> nil end)
    |> ok()
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end


  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit Access Group"))
    |> assign(:page_subtitle, gettext("Fill below form to update this access group details."))
    |> assign_group(id)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Access Group"))
    |> assign(:page_subtitle, gettext("Fill below form to create a new user access group"))
    |> assign(:group, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("User Access Groups"))
    |> assign(:page_subtitle, gettext("Create, update and manage user access groups and their permissions"))
    |> assign(:group, nil)
  end


  def handle_info(_message, socket) do
    socket
    |> stream_groups()
    |> noreply()
  end

  @impl true
  def handle_info({ZippikerWeb.Accounts.Groups.Index, {:saved, group}}, socket) do
    socket
    |> stream_insert(:groups, group)
  end

  # Subscribe connected users to the "group" topic for real-time
  # notifications when changes happen on access group
  defp maybe_subscribe(socket) do
    if connected?(socket), do: ZippikerWeb.Endpoint.subscribe("groups")

    socket
  end

  defp stream_groups(%{assigns: %{current_user: current_user}} = socket) do
    socket |> stream(:groups, get_groups(current_user))
  end

  defp assign_group(%{assigns: %{current_user: current_user}} = socket, group_id) do
    socket
    |> assign(:group, get_group(current_user, group_id))
  end

  defp get_groups(current_user) do
    Zippiker.Accounts.Group
    |> Ash.read!(actor: current_user)
  end

  defp get_group(actor, id) do
    Zippiker.Accounts.Group
    |> Ash.get!(id, actor: actor)
  end
end