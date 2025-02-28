defmodule Zippiker.KnowledgeBase.Tag do
  use Ash.Resource,
    domain: Zippiker.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tags"
    repo Zippiker.Repo
  end

  actions do
    default_accept [:name, :slug]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :slug, :string
    timestamps()
  end

  relationships do
    many_to_many :articles, Zippiker.KnowledgeBase.Article do
      through Zippiker.KnowledgeBase.ArticleTag
      source_attribute_on_join_resource :tag_id
      destination_attribute_on_join_resource :article_id
    end
  end
end
