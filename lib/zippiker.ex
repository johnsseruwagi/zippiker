defmodule Zippiker do
  @moduledoc """
  Zippiker keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defdelegate get_permissions(), to: Zippiker.Accounts.Permission
end
