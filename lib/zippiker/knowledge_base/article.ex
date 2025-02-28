defmodule Zippiker.KnowledgeBase.Article do
  use Ash.Resource,
    domain: Zippiker.KnowledgeBase,
    data_layer: AshPostgres.DataLayer,
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "articles"
    repo Zippiker.Repo
  end

  pub_sub do
    module ZippikerWeb.Endpoint
    prefix "articles"
    publish_all :update, [[:id, nil]]
    publish_all :create, [[:id, nil]]
    publish_all :destroy, [[:id, nil]]
  end

  actions do
    default_accept [
      :title,
      :slug,
      :content,
      :views_count,
      :published,
      :category_id
    ]

    defaults [:create, :read, :update, :destroy]

    create :create_with_category do
      description "Create an article and its category at the same time"
      argument :category_attrs, :map, allow_nil?: false
      change manage_relationship(:category_attrs, :category, type: :create)
    end

    create :create_with_tags do
      description "Create an article with tags"
      argument :tags, {:array, :map}, allow_nil?: false

      change manage_relationship(:tags, :tags,
               on_no_match: :create,
               on_match: :ignore,
               on_missing: :create
             )
    end

    update :add_comment do
      description "Add a comment to an article"
      require_atomic? false
      argument :comment, :map, allow_nil?: false
      change manage_relationship(:comment, :comments, type: :create)
    end
  end

  pub_sub do
    module ZippikerWeb.Endpoint
    prefix "articles"
    publish_all :update, [[:id, nil]]
    publish_all :create, [[:id, nil]]
    publish_all :destroy, [[:id, nil]]
  end

  changes do
    change Zippiker.Changes.Slugify
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
    belongs_to :category, Zippiker.KnowledgeBase.Category do
      source_attribute :category_id
      allow_nil? false
    end

    has_many :comments, Zippiker.KnowledgeBase.Comment do
      destination_attribute :article_id
    end

    # Many-to-many relationship with Tag
    many_to_many :tags, Zippiker.KnowledgeBase.Tag do
      through Zippiker.KnowledgeBase.ArticleTag
      source_attribute_on_join_resource :article_id
      destination_attribute_on_join_resource :tag_id
    end

    has_many :article_feedbacks, Zippiker.KnowledgeBase.ArticleFeedback do
      destination_attribute :article_id
    end

    aggregates do
      count :comment_count, :comments
      count :tag_count, :tags
    end
  end
end
