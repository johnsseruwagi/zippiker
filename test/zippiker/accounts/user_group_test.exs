defmodule Zippiker.Accounts.UserGroupTest do
  use ZippikerWeb.ConnCase, async: false
  import AuthCase

  require Ash.Query

  describe "User Access Group tests" do
    test "Group can be added to user" do

      user = create_user()

      group_attrs = %{name: "accountants", description: "handles billing in the system"}
      {:ok, group} =
      Zippiker.Accounts.Group
      |> Ash.create(group_attrs, actor: user)

      user_group_attrs = %{user_id: user.id, group_id: group.id}

      {:ok, user_group} =
      Zippiker.Accounts.UserGroup
      |> Ash.create(user_group_attrs, actor: user, load: [:user, :group], authorize?: false)

      assert user.current_team == Ash.Resource.get_metadata(user_group, :tenant)
      assert user.id == user_group.user_id
      assert group.id == user_group.group_id

    end
  end
end