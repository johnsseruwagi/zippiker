defmodule Zippiker.Accounts.GroupPermissionTest do
  use ZippikerWeb.ConnCase, async: false
  import AuthCase

  require Ash.Query

  describe "Access Group Permission Tests" do
    test "Permission can be added to a group" do
      perm_attrs = %{action: "read", resource: "category"}
      {:ok, permission} =
        Zippiker.Accounts.Permission
        |> Ash.create(perm_attrs)

        user = create_user()
        group_attrs = %{name: "accountants", description: "can manage bill in the system"}

      {:ok, group} =
         Zippiker.Accounts.Group
        |> Ash.create(group_attrs, actor: user)

         group_perm_attrs = %{group_id: group.id, permission_id: permission.id}
      {:ok, group_perm} =
        Zippiker.Accounts.GroupPermission
        |> Ash.create(group_perm_attrs, actor: user, load: [:group, :permission])

        # confirm that the association happened and in the right tenant

        assert user.current_team == Ash.Resource.get_metadata(group_perm, :tenant)
        assert group_perm.permission_id == permission.id
        assert group_perm.group_id == group.id
    end
  end
end