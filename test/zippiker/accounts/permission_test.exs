defmodule Zippiker.Accounts.PermissionTest do
  use ZippikerWeb.ConnCase
  require Ash.Query

  describe "Test permissions" do
    test "Can add permission" do
      new_permission = %{
        action: "read",
        resource: "category"
      }

      {:ok, _permission} =
        Zippiker.Accounts.Permission
        |> Ash.create(new_permission)

        exists? =
        Zippiker.Accounts.Permission
        |> Ash.Query.filter(action == ^new_permission.action and resource == ^new_permission.resource)
        |> Ash.exists?()

        assert exists?
    end
  end
end