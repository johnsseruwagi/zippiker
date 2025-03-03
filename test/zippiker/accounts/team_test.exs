defmodule Zippiker.Accounts.TeamTest do
  use ZippikerWeb.ConnCase, async: false

  import AuthCase
  
  require Ash.Query
  
  describe "Team tests" do
    test "User team can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user()

      # Create a new team for the user
      team_attrs = %{
        name: "Team 1",
        domain: "team_1",
        owner_user_id: user.id
      }

       team = Ash.create!(Zippiker.Accounts.Team, team_attrs)

      # Create a category in the team_1 schema
      attrs = %{
        name: "Billing",
        slug: "billing",
        description: "Refund requests, billing and account issues"
      }

      {:ok, _category} =
        Zippiker.KnowledgeBase.Category
        |> Ash.Changeset.for_create(
             :create,
             attrs,
             tenant: team.domain  # <-- Specify which tenant should store this data
           )
        |> Ash.create()

      # New team should be stored successfully
      assert Zippiker.Accounts.Team
             |> Ash.Query.filter(domain == ^team.domain)
             |> Ash.Query.filter(owner_user_id == ^team.owner_user_id)
             |> Ash.exists?()

      # New team should be set as the current team on the owner
      assert Zippiker.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(current_team == ^team.domain)
               # authorize?: false disables policy checks
             |> Ash.exists?(authorize?: false)

      # New team should be added to the teams list of the owner
      assert Zippiker.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(teams.id == ^team.id)
             |> Ash.exists?(authorize?: false)
    end
  end
end