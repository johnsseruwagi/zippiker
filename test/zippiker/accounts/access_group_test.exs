defmodule Zippiker.Accounts.AccessGroupTest do
  use ZippikerWeb.ConnCase, async: false

  import AuthCase

  describe "User Access Group Tests" do
    test "All resource actions can be listed for permissions" do

      actions = Zippiker.get_permissions()

      assert actions |> is_list()
    end

    test "Group form renders successfully" do
      user = create_user()

      assigns = %{
        actor: user,
        group_id: nil,
        id: Ash.UUIDV7.generate()
      }

      html = render_component(ZippikerWeb.Accounts.Groups.GroupForm, assigns)

      # Confirm that all necessary fields are there

      assert html =~ "access-group-modal-button"
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ gettext("Submit")
    end

    test "Existing Group renders successfully with the component " do
      user = create_user()
      group = get_group()

      assigns = %{
        actor: user,
        group_id: group.id,
        id: Ash.UUIDv7.generate()
      }

      html = render_component(ZippikerWeb.Accounts.Groups.GroupForm, assigns)

      # Confirm that all necessary fields are there
      assert html =~ "access-group-modal-button"
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ gettext("Submit")

      # Confirm that group data is visible in the form
      assert html =~ group.name
      assert html =~ group.description
    end
  end
end