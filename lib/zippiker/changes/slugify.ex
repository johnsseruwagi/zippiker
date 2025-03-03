defmodule Zippiker.Changes.Slugify do
  use Ash.Resource.Change

  @doc """
  Generate and populate a `slug` attribute while inserting a new records
  """
  def change(changeset, _opts, context) do
    if changeset.action_type == :create do
      changeset
      |> Ash.Changeset.force_change_attribute(:slug, generate_slug(changeset, context))
    else
      changeset
    end
  end

  # Genarates a slug based on the name attribute. If the slug exists already,
  # Then make it unique by prefixing the `-count` at the end of the slug

  defp generate_slug(%{attributes: %{name: name}} = changeset, context) when not is_nil(name) do
    # 1. Generate a slug based on the name
    slug = get_slug_from_name(name)

    # 2. Add the count if slug exists
    case count_similar_slugs(changeset, slug, context) do
      {:ok, 0} -> slug
      {:ok, count} -> "#{slug}-#{count}"
      {:error, error} -> raise error
    end
  end

  # If name is not available, return UUIDv7
  defp generate_slug(_changeset, _context), do: Ash.UUIDv7.generate()

  # Generate a lowercase slug based on the string passed
  defp get_slug_from_name(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\s+/, "-")
  end

  defp count_similar_slugs(changeset, slug, context) do
    require Ash.Query

    changeset.resource
    |> Ash.Query.filter(slug == ^slug)
    |> Ash.count(Ash.Context.to_opts(context))
  end
end
