defmodule Zippiker.Accounts.Team.Changes.AssociateUserToTeam do
  @moduledoc """
  Links a user to a team via the user_teams relationship, enabling team listing for the owner.
  """

  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &associate_owner_to_team/2)
  end

  defp associate_owner_to_team(_changeset, team) do
    params = %{user_id: team.owner_user_id, team_id: team.id}
    {:ok, _user_team} =
    Zippiker.Accounts.UserTeam
    |> Ash.Changeset.for_create(:create, params)
    |> Ash.create()

    {:ok, team}
  end

end