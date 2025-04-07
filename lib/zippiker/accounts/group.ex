defmodule Zippiker.Accounts.Group do
  use Ash.Resource,
    otp_app: :zippiker,
    domain: Zippiker.Accounts,
    data_layer: AshPostgres.DataLayer

    postgres do
      repo Zippiker.Repo
      table "groups"
    end

    multitenancy do
      strategy :context
    end

    actions do
      default_accept [:name, :description]
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
      attribute :name, :string, allow_nil?: false
      attribute :description, :string, allow_nil?: false

      timestamps()
    end

    relationships do
      has_many :permissions, Zippiker.Accounts.GroupPermission do
        description "list of permissions assigned to this group"
        destination_attribute :group_id
      end
    end
end