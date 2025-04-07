defmodule Zippiker.Accounts.AccessGroupTest do
  use ZippikerWeb.ConnCase, async: false

  describe "User Access Group Tests" do
    test "All resource actions can be listed for permissions" do

      actions = Zippiker.get_permissions()

      assert actions |> is_list()
    end
  end
end