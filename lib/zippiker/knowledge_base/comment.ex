defmodule Zippiker.KnowledgeBase.Comment do
  use Ash.Resource,
      domain: Zippiker.KnowledgeBase,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "comments"
    repo Zippiker.Repo
  end

  actions do
    default_accept [:content]
    defaults [:create, :read, :update, :destroy ]
  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string, allow_nil?: false
    timestamps()
  end
  relationships do
    belongs_to :article, Zippiker.KnowledgeBase.Article do
      source_attribute :article_id
      allow_nil? false
    end
  end
end