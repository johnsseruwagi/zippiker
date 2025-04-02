defmodule Zippiker.Changes.SetTenant do
  @moduledoc """
  Sets the user’s current_team as the tenant for the change query
  if no tenant’s already provided.
  """
  use Ash.Resource.Change

  @doc """
  Sets the tenant on changes:
  1. If neither tenant nor actor is provided, skip it.
  2. If tenant’s missing but actor’s there, use the actor’s current_team.
  3. Otherwise, leave it alone and move on.
  """
  def change(changeset, _opts, %{tenant: nil, actor: nil} = _context), do: changeset

  def change(changeset, _opts, %{tenant: nil, actor: actor} = _context) do
    Ash.Changeset.set_tenant(changeset, actor.current_team)
  end

  def change(changeset, _opts, _context), do: changeset
end