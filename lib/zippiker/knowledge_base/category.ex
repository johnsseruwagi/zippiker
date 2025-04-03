defmodule Zippiker.KnowledgeBase.Category do
  use Ash.Resource,
    # Tell Ash that this resource belongs to KnowledgeBase domain
    domain: Zippiker.KnowledgeBase,
    # Tell Ash that this resource data is stored in a postgresql
    data_layer: AshPostgres.DataLayer,
    # Tell Ash to broadcast/ Emit events via pubsub
    notifiers: Ash.Notifier.PubSub,
    authorizers: Ash.Policy.Authorizer

  policies do
    policy always() do
      authorize_if Zippiker.Accounts.Checks.Authorized
    end
  end

  multitenancy do
    strategy :context
  end

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

    read :most_recent do
      prepare Zippiker.Preparations.LimitTo5
      prepare Zippiker.Preparations.MonthToDate
      prepare {Zippiker.Preparations.OrderByMostRecent, attribute: :inserted_at}
    end
  end

  # Configure how ash will work with pubsub on this resource.
  pub_sub do
    # 1. Tell Ash to use ZippikerWeb.Endpoint for publishing events
    module ZippikerWeb.Endpoint

    # Prefix all events from this resource with category. This allows us
    # to subscribe only to events starting with "categories" in live view
    prefix "categories"

    # Define event topic or names. Below configuration will be publishing
    # topic of this format whenever an action of update, create or delete
    # happens:
    #    "categories"
    #    "categories:UUID-PRIMARY-KEY-ID-OF-CATEGORY"
    #
    #  You can pass any other parameter available on resource like slug
    publish_all :update, [[:id, nil]]
    publish_all :create, [[:id, nil]]
    publish_all :destroy, [[:id, nil]]
  end

  changes do
    change {Zippiker.Changes.Slugify, attribute: :slug}
    change Zippiker.Changes.SetTenant
  end

  preparations do
    prepare Zippiker.Preparations.SetTenant
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
      # This resource has a source_attribute option that defaults to the :id attribute
    end

    aggregates do
      count :article_count, :articles
    end
  end
end
