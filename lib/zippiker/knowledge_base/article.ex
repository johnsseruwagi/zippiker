defmodule Zippiker.KnowledgeBase.Article do
  use Ash.Resource,
      domain:  Zippiker.KnowledgeBase,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "articles"
    repo Zippiker.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :slug, :string
    attribute :content, :string
    attribute :views_count, :integer, default: 0
    attribute :published, :boolean, default: false
    # Automatically adds, inserted_at and updated_at columns
    timestamps()
  end

  relationships do
    belongs_to :category,  Zippiker.KnowledgeBase.Category do
      source_attribute :category_id
      allow_nil? false
    end

    has_many :comments,  Zippiker.KnowledgeBase.Comment do
      destination_attribute :article_id
    end

    # Many-to-many relationship with Tag
    many_to_many :tags,  Zippiker.KnowledgeBase.Tag do
      through  Zippiker.KnowledgeBase.ArticleTag
      source_attribute_on_join_resource :article_id
      destination_attribute_on_join_resource :tag_id
    end

    has_many :article_feedbacks,  Zippiker.KnowledgeBase.ArticleFeedback do
      destination_attribute :article_id
    end
  end
end