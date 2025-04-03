defmodule Zippiker.KnowledgeBase.Article.Changes.DeleteRelatedComment do
  @moduledoc """
  Change to delete all comments belonging to an article before
  deleting the article itself
  """

  use Ash.Resource.Change
  require Ash.Query

  @impl true
  def change(%Ash.Changeset{action_type: :destroy} = changeset, _opts, _context) do
    Ash.Changeset.before_action(changeset, &delete_related_comments/1)
  end

  defp delete_related_comments(%{tenant: tenant, data: data} = changeset) do
    opts = [tenant: tenant, authorize?: false]
    get_related_comments(data, opts)
    |> delete_comments(opts)

    changeset
  end

  defp get_related_comments(article, opts) do
    Zippiker.KnowledgeBase.Comment
    |> Ash.Query.filter(article_id == ^article.id)
    |> Ash.read!(opts)
  end

  defp delete_comments([], _opts), do: %Ash.BulkResult{status: :success}

  defp delete_comments(records, opts), do: Ash.bulk_destroy!(records, :destroy, %{}, opts)

end