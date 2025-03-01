defmodule Zippiker.KnowledgeBase.ArticleTag do
  use Ash.Resource,
    domain: Zippiker.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  multitenancy do
    strategy :context
  end

  postgres do
    table "article_tags"
    repo Zippiker.Repo
  end

  actions do
    default_accept [:article_id, :tag_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id
    timestamps()
  end

  relationships do
    belongs_to :article, Zippiker.KnowledgeBase.Article do
      source_attribute :article_id
    end

    belongs_to :tag, Zippiker.KnowledgeBase.Tag do
      source_attribute :tag_id
    end
  end

  identities do
    identity :unique_article_tag, [:article_id, :tag_id]
  end
end
