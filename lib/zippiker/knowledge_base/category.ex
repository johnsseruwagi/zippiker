defmodule Zippiker.KnowledgeBase.Category do
  use Ash.Resource,
      # Tell Ash that this resource belongs to KnowledgeBase domain
  domain: Zippiker.KnowledgeBase,
        # Tell Ash that this resource data is stored in a postgresql
  data_layer: AshPostgres.DataLayer

  postgres do
    # Tell Ash that this resource data is stored in a table named "categories"

    table "categories"
    # Tell Ash that this resource access data storage via Zippiker.Repo
    repo Zippiker.Repo

    # Delete related articles when a category is destroyed to prevent
    # leave records behind

    references do
      reference :articles, on_delete: :delete
    end
  end

  actions do
    # Tell Ash what columns to accept while inserting or updating
    default_accept [:name, :slug, :description]
    # Tell Ash what actions are allowed on this resource
    defaults [:create, :read, :update, :destroy]

    update :create_article do
      description "Create an article under a specified category"
      # Set atomic to false since this is a 2-steps operation.
      require_atomic? false
      # Specify the parameter that will hold article attributes
      argument :article_attrs, :map, allow_nil?: false
      change manage_relationship(:article_attrs, :articles, type: :create)
    end

    create :create_with_article do
      description "Create a Category and an article under it"
      argument :article_attrs, :map, allow_nil?: false
      change manage_relationship(:article_attrs, :articles, type: :create)
    end
  end

  # Tell Ash what columns the resource has and their types and validations

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :slug, :string
    attribute :description, :string, allow_nil?: true
    # Automatically adds, inserted_at and updated_at columns
    timestamps()
  end

  # Relationship Block. In this case this resource has many articles
  relationships do
    has_many :articles, Zippiker.KnowledgeBase.Article do
      description "Relationship with the articles."
      # Tell Ash that the articles table has a column named "category_id" that references this resource
      destination_attribute :category_id
    end

    aggregates do
      count :article_count, :articles
    end
  end
end