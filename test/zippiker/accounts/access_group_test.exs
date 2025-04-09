defmodule Zippiker.Accounts.AccessGroupTest do
  use ZippikerWeb.ConnCase, async: false


  describe "User Access Group Tests" do
    test "All resource actions can be listed for permissions" do

      actions = Zippiker.get_permissions()

      assert actions |> is_list()
    end
  end

  describe "Group Form tests" do
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
    test "Renders the form with populated fields when editing an existing group" do
      user = create_user()
      group = get_group(user)

      form =
        group
        |> Form.for_update(:update, as: "group", actor: user)
        |> to_form()

      assigns = %{
        id: id(),
        title: title("Edit"),
        subtitle: subtitle("editing an access group"),
        form: form,
        group: group,
        myself: nil,
        patch: "/accounts/groups/#{group.id}",
        actor: user
      }

      html =
        render_component(&ZippikerWeb.Accounts.Groups.GroupForm.render/1, assigns)

      # Assertions to verify the component renders correctly with existing data
      assert html =~ "access-group-#{assigns.id}"
      assert html =~ "#{assigns.title}"
      assert html =~ "#{assigns.subtitle}"
      assert html =~ gettext("Access Group Name")
      assert html =~ gettext("Description")
      assert html =~ gettext("Submit")

      # Confirm that group data is visible in the form
      assert html =~ group.name
      assert html =~ group.description
    end
    test "update/2 assigns the form correctly for new group" do
      user = create_user()

      assigns = %{
        id: id(),
        actor: user,
        title: title("New group"),
        subtitle: subtitle("This is for a new group"),
        group: nil,
        patch: "/accounts/groups"
      }

      {:ok, socket} =
        ZippikerWeb.Accounts.Groups.GroupForm.update(assigns, %Phoenix.LiveView.Socket{})

      # Confirm that the form was assigned
      assert socket.assigns.id == assigns.id
      assert socket.assigns.title == assigns.title
      assert socket.assigns.subtitle == assigns.subtitle
      refute is_nil(socket.assigns.form)
    end
    test "update/2 assigns the form correctly for existing group" do
      user = create_user()
      group = get_group(user)

      assigns = %{
        id: id(),
        actor: user,
        title: title("New group"),
        subtitle: subtitle("This is for a new group"),
        group: group,
        patch: "/accounts/groups"
      }

      {:ok, socket} =
        ZippikerWeb.Accounts.Groups.GroupForm.update(assigns, %Phoenix.LiveView.Socket{})

      # Confirm that the form was assigned
      assert socket.assigns.id == assigns.id
      assert socket.assigns.title == assigns.title
      assert socket.assigns.subtitle == assigns.subtitle
      refute is_nil(socket.assigns.form)
    end
  end

  describe "Group Form events tests" do

    test "handle_event/3 validates form input" do
      user = create_user()
      group_params = %{
        name: "New group",
        description: "Test description"
      }

      form =
        Zippiker.Accounts.Group
        |> Form.for_create(:create, as: "group", actor: user)
        |> to_form()

      # Create a properly structured LiveView socket
      socket =
        %Phoenix.LiveView.Socket{
          assigns: %{
            actor: user,
            form: form,
            __changed__: %{}
          }
        }

      # Mock Form.validate to avoid actual validation
      with_mock Form, validate: fn _form, _param -> :validated_form end do
        {:noreply, updated_socket} =
        ZippikerWeb.Accounts.Groups.GroupForm.handle_event("validate", %{"group" => group_params}, socket)

        assert updated_socket.assigns.form == :validated_form
      end
    end
    test "handle_event/3 handles successful form submission" do
      user = create_user()
      group_params = %{
        name: "New group",
        description: "Test description"
      }

      form =
        Zippiker.Accounts.Group
        |> Form.for_create(:create, as: "group", actor: user)
        |> to_form()

      # Create a properly structured LiveView socket
      socket =
        %Phoenix.LiveView.Socket{
          assigns: %{
            actor: user,
            form: form,
            patch: "/accounts/groups",
            __changed__: %{},
            flash: %{}
          }
        }

      # Define the created_group mock object
      created_group = %Zippiker.Accounts.Group{
        id: id(),
        name: "New Group",
        description: "Test description"
      }

      # Mock Form.submit to simulate actual creation
      with_mock Form, submit: fn _form, [params: _] -> {:ok, created_group} end do
        {:noreply, %{assigns: %{flash: %{"info" => info}}} = _updated_socket} =
        ZippikerWeb.Accounts.Groups.GroupForm.handle_event("save", %{"group" => group_params}, socket)

        # Check that the proper flash message was set
        assert info == "Access Group Submitted."
      end
    end

  end


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
#
#   end
end