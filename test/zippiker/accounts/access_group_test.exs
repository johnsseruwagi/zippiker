defmodule Zippiker.Accounts.AccessGroupTest do
  use ZippikerWeb.ConnCase, async: false


  describe "User Access Group Tests" do
    test "All resource actions can be listed for permissions" do

      actions = Zippiker.get_permissions()

      assert actions |> is_list()
    end

    test "Group form renders successfully" do
      user = create_user()

      form =
        Zippiker.Accounts.Group
        |> Form.for_create(:create, as: "group", actor: user)
        |> to_form()

      assigns = %{
        actor: user,
        group: nil,
        id: id(),
        title: title("form renders"),
        form: form,
        subtitle: subtitle("this is a form"),
        myself: nil,
        patch: "/accounts/groups"
      }

      html = render_component(&ZippikerWeb.Accounts.Groups.GroupForm.render/1, assigns)

      # Assertions to verify the component renders correctly
      assert html =~ "access-group-#{assigns.id}"
      assert html =~ "#{assigns.title}"
      assert html =~ "#{assigns.subtitle}"
      assert html =~ "group[name]"
      assert html =~ "group[description]"
      assert html =~ gettext("Submit")

      # Verify form fields exist
      assert html =~ ~r/<input[^>]*id="access-group-name#{assigns.id}"/
      assert html =~ ~r/<textarea[^>]*id="access-group-description#{assigns.id}"/
#      assert html =~ ~r/<button[^>]*>Submit<\/button>/
    end

#    test "Existing Group renders successfully with the component " do
#      user = create_user()
#      group = get_group(user)
#
#      assigns = %{
#        actor: user,
#        group_id: group.id,
#        id: Ash.UUIDv7.generate()
#      }
#
#      html = render_component(ZippikerWeb.Accounts.Groups.GroupForm, assigns)
#
#      # Confirm that all necessary fields are there
##      assert html =~ "access-group-modal-button"
#      assert html =~ "form[name]"
#      assert html =~ "form[description]"
#      assert html =~ gettext("Submit")
#
#      # Confirm that group data is visible in the form
#      assert html =~ group.name
#      assert html =~ group.description
#    end
#
#    test "Guests should be redirected to login while trying to access /accounts/groups", %{conn: conn} do
#      assert conn
#          |> live(~p"/accounts/groups")
#          |> follow_redirect(conn, ~p"/sign-in")
#    end
#
#    test "Access Groups can be listed", %{conn: conn} do
#      user = create_user()
#      groups = get_groups(user)
#
#      {:ok, _view, html} =
#        conn
#        |> login(user)
#        |> live(~p"/accounts/groups")
#
#      # Confirm that all the groups are listed
#      for group <- groups do
#        assert html =~ group.name
#        assert html =~ group.description
#      end
#
#    end
#
#    test "Access Group can be created", %{conn: conn} do
#      user = create_user()
#
#      {:ok, view, _html} =
#        conn
#        |> login(user)
#        |> live(~p"/accounts/groups")
#
#      attrs = %{
#        name: "Support",
#        description: "Customer support representative"
#      }
#
#      # Form can be validated
#      assert view
#             |> form("access-group-form", form: attrs)
#             |> render_change()
#
#      # Form can be submitted
#      assert view
#             |> form("access-group-form", form: attrs)
#             |> render_submit()
#
#      # Confirm that data was actually created
#      require Ash.Query
#
#      assert Zippiker.Accounts.Group
#            |> Ash.Query.filter(name == ^attrs.name)
#            |> Ash.Query.filter(description == ^attrs.description)
#            |> Ash.exists!(actor: user)
#    end
#
#    test "Access Group can be edited", %{conn: conn} do
#      user = create_user()
#      group = get_group(user)
#
#      {:ok, view, html} =
#        conn
#        |> login(user)
#        |> live(~p"/accounts/groups")
#
#      # Confirm that the group is visible on the page
#      assert html =~ group.name
#      assert html =~ group.description
#      assert html =~ ~p"/accounts/groups/#{group.id}"
#
#      # Confirm user can click on the link to group edit
#      assert view
#        |> element("#edit-access-group-#{group.id}")
#        |> render_click()
#
#      assert view
#        |> element("#access-group-permissions-#{group.id}")
#        |> render_click()
#        |> follow_redirect(conn, ~p"/accounts/groups/#{group.id}")
#
#      # Confirm that the edit group page displays the group details
#      {:ok, edit_view, edit_html} =
#        conn
#        |> login(user)
#        |> live(~p"/accounts/groups/#{group.id}")
#
#      assert edit_html =~ group.name
#      assert edit_html =~ group.description
#      assert edit_html =~ "form[name]"
#      assert edit_html =~ "form[description]"
#
#      # Confirm that user can see all the permissions in the app listed
#      for perm <- Zippiker.get_permissions() do
#        assert edit_html =~ perm.action
#        assert edit_html =~ perm.resource
#
#        # Confirm the permission is clickable
#        assert edit_view
#               |> element("#group-permission-#{perm.resource}-#{perm.action}")
#               |> render_click()
#      end
#
#    end

   end
end