defmodule Zippiker.KnowledgeBase.ArticleFeedback do
  use Ash.Resource,
    domain: Zippiker.KnowledgeBase,
    data_layer: AshPostgres.DataLayer

  multitenancy do
    strategy :context
  end

  postgres do
    table "article_feedbacks"
    repo Zippiker.Repo
  end

  actions do
    default_accept [:helpful, :feedback, :article_id]
    defaults [:create, :read, :update, :destroy]
  end
  attributes do
    uuid_primary_key :id

    attribute :helpful, :boolean, default: false
    attribute :feedback, :string, allow_nil?: true

    create_timestamp :created_at
  end

  changes do
    change Zippiker.Changes.SetTenant
  end

  preparations do
    prepare Zippiker.Preparations.SetTenant
  end

  relationships do
    belongs_to :article, Zippiker.KnowledgeBase.Article do
      source_attribute :article_id
      allow_nil? false
    end
  end

end
