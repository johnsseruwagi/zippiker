defmodule Zippiker.Repo.TenantMigrations.AddCategoryOnDeleteToArticle do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint(:articles, "articles_category_id_fkey")

    alter table(:articles, prefix: prefix()) do
      modify :category_id,
             references(:categories,
               column: :id,
               name: "articles_category_id_fkey",
               type: :uuid,
               prefix: prefix(),
               on_delete: :delete_all
             )
    end
  end

  def down do
    drop constraint(:articles, "articles_category_id_fkey")

    alter table(:articles, prefix: prefix()) do
      modify :category_id,
             references(:categories,
               column: :id,
               name: "articles_category_id_fkey",
               type: :uuid,
               prefix: prefix()
             )
    end
  end
end
