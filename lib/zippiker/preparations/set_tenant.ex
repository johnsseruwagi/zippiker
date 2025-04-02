defmodule Zippiker.Preparations.SetTenant do
  @moduledoc """
  Sets the user’s current_team as the tenant for read queries
  if no tenant’s provided.
  """
  use Ash.Resource.Preparation

  @doc """
  Sets the tenant on preparations:
  1. If neither tenant nor actor is provided, skip it.
  2. If tenant’s missing but actor’s there, use the actor’s current_team.
  3. Otherwise, keep calm and carry on.
  """
  def prepare(query, _opts, %{tenant: nil, actor: nil} = _context), do: query
  def prepare(query, _opts, %{tenant: nil, actor: actor} = _context) do
    Ash.Query.set_tenant(query, actor.current_team)
  end

  def prepare(query, _opts, _context), do: query
end