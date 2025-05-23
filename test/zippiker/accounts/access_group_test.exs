defmodule Zippiker.Accounts.AccessGroupTest do
  use ZippikerWeb.ConnCase, async: false

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "updated name", description: "updated description"}
  @invalid_attrs %{name: nil, description: nil}

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
    test "handle_event/3 handles form submission errors" do
      user = create_user()
      group_params = %{
        name: "",
        description: ""
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

      error_form = :form_with_errors

      # Mock Form.submit to simulate actual creation
      with_mock Form, submit: fn _form, [params: _] -> {:error, error_form} end do
        {:noreply, updated_socket} =
        ZippikerWeb.Accounts.Groups.GroupForm.handle_event("save", %{"group" => group_params}, socket)

        # Check that the proper flash message was set
        assert updated_socket.assigns.form == error_form
      end
    end
  end

  describe "Index" do
    test "Guests should be redirected to login while trying to access /accounts/groups", %{conn: conn} do
      assert conn
        |> live(~p"/accounts/groups")
        |> follow_redirect(conn, ~p"/sign-in")
    end
    test "List all groups", %{conn: conn} do
      user = create_user()
      groups = get_groups(user)

      {:ok, _index_live, html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups")


        assert html =~ "User Access Groups"
        assert html =~ "Create, update and manage user access groups and their permissions"

        for group <- groups do
          assert html =~ group.name
          assert html =~ group.description
        end

    end
    test "Saves new group", %{conn: conn} do
      user = create_user()

      {:ok, index_live, _html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups")

      # Click the link that contains the add button
      # Note: We're clicking the link, not the button itself
        assert index_live
          |> element( "a[href='/accounts/groups/new']")
          |> render_click()

        assert_patch(index_live, ~p"/accounts/groups/new")

        # Form can be validated
        assert index_live
          |> form("#access-group-form", group: @invalid_attrs)
          |> render_change() =~ gettext("is required")

        # Form can be submitted
        assert index_live
          |> form("#access-group-form", group: @create_attrs)
          |> render_submit()

        assert_patch(index_live, ~p"/accounts/groups")

        html = render(index_live)

        assert html =~ gettext("Access Group Submitted.")

        # Confirm that the data was actually created
        require Ash.Query

        assert Zippiker.Accounts.Group
          |> Ash.Query.filter(name == ^@create_attrs.name)
          |> Ash.Query.filter(description == ^@create_attrs.description)
          |> Ash.exists?(actor: user)
    end
    test "Updates group in listing", %{conn: conn} do
      user = create_user()
      group = get_group(user)

      {:ok, index_live, html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups")

      # Confirm that the group is visible on the page
        assert html =~ group.name
        assert html =~ group.description
        assert html =~ ~p"/accounts/groups/#{group.id}/edit"

        # Confirm that a link to edit is available
        assert index_live
          |> element("a[href='/accounts/groups/#{group.id}/edit']")
          |> render_click() =~ gettext("Edit")


        assert_patch(index_live, ~p"/accounts/groups/#{group.id}/edit")

        # Form can be validated
        assert index_live
          |> form("#access-group-form", group: @invalid_attrs)
          |> render_change() =~ gettext("is required")

        # Form can be submitted
        assert index_live
          |> form("#access-group-form", group: @update_attrs)
          |> render_submit()

        assert_patch(index_live, ~p"/accounts/groups")

        new_html = render(index_live)
        assert new_html =~ gettext("Access Group Submitted.")

        # Confirm that the group was actually updated
        require Ash.Query
        exists? =
          Zippiker.Accounts.Group
          |> Ash.Query.filter(name == ^@update_attrs.name)
          |> Ash.Query.filter(description == ^@update_attrs.description)
          |> Ash.exists?(actor: user)

          assert exists?

    end
    test "Edit page displays group", %{conn: conn} do
      user = create_user()
      group = get_group(user)

      {:ok, _edit_live, html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups/#{group.id}/edit")

        # Confirm that group details are displayed correctly
        assert html =~ group.name
        assert html =~ group.description
        assert html =~ "group[name]"
        assert html =~ "group[description]"

        # Confirm that the page title and subtitle are displayed
        assert html =~ gettext("Edit Access Group")
        assert html =~ gettext("Fill below form to update this access group details.")

    end
  end

  describe "Permission" do
    test "Guests should be redirected to login", %{conn: conn} do

      user = create_user()
      group = get_group(user)

      assert conn
        |> live(~p"/accounts/groups/#{group.id}/permissions")
        |> follow_redirect(conn, ~p"/sign-in")
    end
    test "Permissions page displays group details", %{conn: conn} do
      user = create_user()
      group = get_group(user)

      {:ok, _permission_live, html} =
        conn
        |> login(user)
        |> live(~p"/accounts/groups/#{group.id}/permissions")

        assert html =~ gettext("%{name} Access Permission", name: group.name)
        assert html =~ gettext("%{description}", description: group.description)
        assert html =~ gettext("Back to access groups")
    end
  end

end