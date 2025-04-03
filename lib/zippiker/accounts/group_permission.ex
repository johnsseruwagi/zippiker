defmodule Zippiker.Accounts.GroupPermission do
  use Ash.Resource,
    otp_app: :zippiker,
    domain: Zippiker.Accounts,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub]

    postgres do
      repo Zippiker.Repo
      table "group_permissions"
    end

    actions do
      default_accept [:permission_id, :group_id]
      defaults [:create, :read, :update, :destroy]
    end

    multitenancy do
      strategy :context
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
      belongs_to :group, Zippiker.Accounts.Group do
        description "Relationship with Group inside tenant"
        source_attribute :group_id
        allow_nil? false
      end

      belongs_to :permission, Zippiker.Accounts.Permission do
        description "Permission for user access group"
        source_attribute :permission_id
        allow_nil? false
      end
    end

    identities do
      identity :unique_name, [:group_id, :permission_id ]
    end
end