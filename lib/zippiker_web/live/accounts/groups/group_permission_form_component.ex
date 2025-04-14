defmodule ZippikerWeb.Accounts.Groups.GroupPermissionFormComponent do
  use ZippikerWeb, :live_component
  alias AshPhoenix.Form

  attr :group_id, :string, required: true
  attr :actor, Zippiker.Accounts.User, required: true
  attr :group_permissions, :any, required: true
  def form(assigns) do
    ~H"""
      <.live_component
        module={__MODULE__}
        group_id={@group_id}
        actor={@actor}
        group_permissions={@group_permissions}
        id={@group_id}
      />
    """
  end

  def render(assigns) do
    ~H"""
    <div id={"access-group-permissions-#{@group_id}"}>
      <form id={"access-group-permission-form-#{@group_id}"} phx-submit="save" phx-target={@myself}>
        <div class="flex justify-between items-center mb-6">
          <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
            <input
              type="checkbox"
              id={"select-all-#{@group_id}"}
              phx-hook="SelectAllPermissions"
              data-group-id={@group_id}
              class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
            />
            <span class="font-medium">{gettext("Select All Permissions")}</span>
          </label>
          <div>
            <.button>{gettext("Submit")}</.button>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <div :for={{resource_name, perms} <- get_resource_permissions()}>
            <div class="resource-group mb-6">
              <h3 class="text-lg font-medium text-zinc-900 border-b pb-2 mb-3 flex items-center justify-between">
                <label class="flex items-center gap-2 text-sm text-zinc-600">
                  <input
                    type="checkbox"
                    id={"select-all-#{resource_name}-#{@group_id}"}
                    phx-hook="SelectResourcePermissions"
                    data-resource={resource_name}
                    data-group-id={@group_id}
                    class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
                  />
                  {get_resource_name(resource_name)}
                </label>
              </h3>
              <div class="mt-2 space-y-2 pl-4">
                <div :for={perm <- perms}>
                  <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
                    <input type="hidden" name={"form[#{perm.resource}][#{perm.action}]"} />
                    <input
                      type="checkbox"
                      checked={group_has_permission?(perm.resource, perm.action, @group_permissions)}
                      class="rounded border-zinc-300 text-zinc-900 focus:ring-0 permission-checkbox"
                      id={"access-group-permission-#{perm.resource}-#{perm.action}"}
                      name={"form[#{perm.resource}][#{perm.action}]"}
                      data-resource={perm.resource}
                    />
                    {Phoenix.Naming.humanize(perm.action)}
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>
        <.button>{gettext("Submit")}</.button>
      </form>
    </div>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> ok()
  end

  def handle_event("save", %{"form" => permissions}, socket) do
    case save_group_permissions(permissions, socket) do
      %Ash.BulkResult{status: :success} ->
        socket
        |> put_flash(:info, "Permissions updated successfully")
        |> noreply()
      error ->
        dbg(error)

        socket
        |> put_flash(:error, "Unable to update permissions")
        |> noreply()
    end
  end

  defp save_group_permissions(permission, socket) do
    %{current_user: actor, group_id: group_id, group_permissions: permissions} = socket.assigns

    # Remove all existing permissions
    Ash.bulk_destroy!(
      permissions,
      :destroy,
      %{},
      batch_size: 300,
      domain: Zippiker.Accounts,
      tenant: actor.current_team
    )

    # Add new permissions
    permissions
    |> transform_permissions(group_id)
    |> Ash.bulk_create!(
      Zippiker.Accounts.GroupPermission,
      :create,
      actor: actor,
      tenant: actor.current_team,
      return_errors?: true,
      upsert_fields: [:group_id],
      upsert_identity: :unique_group_permission
       )
  end

  # Transforms permissions
  defp transform_permissions(permissions, group_id) do
    permissions
    |> convert_to_list()
    |> transform_resources(group_id)
    |> flatten_permissions()
    |> filter_authorized()
    |> remove_authorized_flag()
  end

  # Convert the permissions to a list of key-value tuples
  defp convert_to_list(permissions), do: Map.to_list(permissions)

  # Transforms each resource and its permissions into structured maps
  defp transform_resources(resource_list, group_id) do
    Enum.map(
      resource_list,
      fn {resource, permissions} ->
        permissions
        |> Map.to_list()
        |> transform_permissions_for_resources(resource, group_id)
      end
    )
  end

  # Transforms individual permissions for a given resource
  defp transform_permissions_for_resources(permissions, resource, group_id) do
    Enum.map(permissions, fn {action, authorized?} ->
      %{
        group_id: group_id,
        resource: resource,
        action: action,
        authorized?: authorized? == "on"
      }
    end)
  end

  # Flattens the nested list structure into a single list
  defp flatten_permissions(nested_perms) do
    Enum.flat_map(nested_perms, & &1)
  end

  # Keeps only the permissions that are authorized
  defp filter_authorized(perms) do
    Enum.filter(perms, & &1.authorized?)
  end

  # Removes the authorized? flag from each permission map
  defp remove_authorized_flag(perms) do
    Enum.map(perms, &Map.delete(&1, :authorized?))
  end

  defp get_resource_permissions do
    Zippiker.get_permissions()
    |> Enum.group_by(& &1.resource)
    |> Enum.sort_by(fn {resource, _perms} -> resource end, :asc)
  end
  defp get_resource_name(resource_name) do
    resource_name
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.at(-1)
    |> Phoenix.Naming.humanize()
  end
  defp group_has_permission?(resource, action, group_permissions) do
    group_permissions
    |> Enum.any?(fn group_perm ->
      group_perm.action == action |> to_string() &&
        group_perm.resource == resource |> to_string()
    end)
  end
end