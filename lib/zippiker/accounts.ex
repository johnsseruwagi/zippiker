defmodule Zippiker.Accounts do
  use Ash.Domain,
    otp_app: :zippiker

  resources do
    resource Zippiker.Accounts.Token
    resource Zippiker.Accounts.User
    resource Zippiker.Accounts.Team
    resource Zippiker.Accounts.UserTeam
    resource Zippiker.Accounts.Group
    resource Zippiker.Accounts.GroupPermission
    resource Zippiker.Accounts.UserGroup
  end
end
