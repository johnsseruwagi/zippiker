defmodule ZippikerWeb.Accounts.Groups.GroupPermissionsLive do
  use ZippikerWeb, :live_view

  def render(assigns) do
    ~H"""
      <.back navigate={~p"/accounts/groups"} > {gettext("Back to access groups")}</.back>
      <.header class="mt-4" >
        <.icon name="hero-shield-check"/> {gettext("%{name} Access Permissions", name: @group.name)}
        <:subtitle>{gettext("%{description}", description: @group.description)}</:subtitle>
      </.header>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    socket
    |> assign(:group_id, id)
    |> assign_group()
    |> ok()
  end

  defp assign_group(%{assigns: %{current_user: actor, group_id: id}} = socket) do
    socket |> assign(:group, get_group!(id, actor))
  end

  defp get_group!(id, actor) do
    Zippiker.Accounts.Group
    |> Ash.get!(id, actor: actor)
  end

  #      <div class="mt-4" >
  #          <ZippikerWeb.Accounts.Groups.GroupPermissionFormComponent.form
  #            group_id={@group_id}
  #            actor={@current_user}
  #          />
  #      </div>
end