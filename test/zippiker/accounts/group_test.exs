defmodule Zippiker.Accounts.GroupTest do
  use ZippikerWeb.ConnCase
  require Ash.Query

  import AuthCase

  describe "Group tests" do
    test "can create group" do
      user = create_user()

      new_group = %{
        name: "accountants",
        description: "Handles Billing"
      }

      {:ok, _group} =
        Zippiker.Accounts.Group
        |> Ash.create(new_group, actor: user)

        exists? =
        Zippiker.Accounts.Group
        |> Ash.Query.filter(name == ^new_group.name and description == ^new_group.description)
        |> Ash.exists?(actor: user)

        assert exists?
    end
  end
end