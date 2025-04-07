defmodule AuthCase do

  require Ash.Query

  def login(conn, user) do
    case AshAuthentication.Jwt.token_for_user(user, %{}, domain: Zippiker.Accounts) do
      {:ok, token, _claims} ->
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Plug.Conn.put_session(:user_token, token)

      {:error, reason} ->
      raise "Failed to generate token: #{inspect(reason)}"
    end
  end

  def create_user() do
    user_params = %{
      email: "john.tester@example.com",
      current_team: "team_1"}

    user = Ash.Seed.seed!(Zippiker.Accounts.User, user_params)

    team_attrs = %{
      name: "Team 1",
      domain: "team_1",
      owner_user_id: user.id}

    team = Ash.Seed.seed!(Zippiker.Accounts.Team, team_attrs)
    Ash.Seed.seed!(Zippiker.Accounts.UserTeam, %{user_id: user.id, team_id: team.id})

    user
  end

  def get_group(user \\ nil) do
    actor = user || create_user()

    case Ash.read_first(Zippiker.Accounts.Group, actor: actor) do
      {:ok, nil} -> create_groups(actor) |> Enum.at(0)
      {:ok, group} -> group
    end
  end

  def get_groups(user \\ nil) do
    actor = user || create_user()

    case Ash.read(Zippiker.Accounts.Group, actor: actor) do
      {:ok, []} -> create_groups(actor)
      {:ok, groups} -> groups
    end
  end

  def create_groups(user \\ nil) do
    actor = user || create_user()

    group_attrs = [
      %{name: "Accountant", description: "Finance accountant"},
      %{name: "Manager", description: "Team manager"},
      %{name: "Developer", description: "Software developer"},
      %{name: "Admin", description: "System administrator"},
      %{name: "HR", description: "Human resources specialist"}
    ]

    Ash.Seed.seed!(Zippiker.Accounts.Group, group_attrs, tenant: actor.current_team)
  end

end