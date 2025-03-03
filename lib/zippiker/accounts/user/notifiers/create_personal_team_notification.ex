defmodule Zippiker.Accounts.User.Notifiers.CreatePersonalTeamNotification do
  alias Ash.Notifier.Notification
  alias Zippiker.Accounts.Team
  use Ash.Notifier

  def notify(%Notification{data: user, action: %{name: :register_with_password}}) do
    create_personal_team(user)
  end

  def notify(%Notification{} = _notification), do: :ok

  defp create_personal_team(user) do
    # Determine the count of existing team and use it as a
    # suffix to the team domain.
    team_count = Ash.count!(Team) + 1

    team_attrs = %{
      name: "Personal Team",
      domain: "personal_team_#{team_count}",
      owner_user_id: user.id
    }

    Ash.create!(Team, team_attrs)
  end

end