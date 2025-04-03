defmodule Zippiker.Accounts.UserGroup do
  use Ash.Resource,
    otp_app: domain,
    domain: Zippiker.Accounts,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]


    postgres do
      repo Zippiker.Repo
      table "user_groups"
    end

    multitenancy do
      strategy :context
    end

    actions do
      default_accept [:user_id, :group_id]
      defaults [:create, :read, :update, :destroy]
    end

    changes do
      change Zippiker.Changes.SetTenant
    end

    preparations do
      prepare Zippiker.Preparations.SetTenant
    end

    attributes do
      uuid_v7_primary_key :id

      timestamps()
    end

    relationships do
      belongs_to :user, Zippiker.Accounts.User do
        description "Permission for user access group"
        source_attribute :user_id
        allow_nil? false
      end

      belongs_to :group, Zippiker.Accounts.Group do
        description "Relationship with group in a tenant"
        source_attribute :group_id
        allow_nil? false
      end
    end

    identities do
      identity :unique_name, [:user_id, :group_id]
    end
end