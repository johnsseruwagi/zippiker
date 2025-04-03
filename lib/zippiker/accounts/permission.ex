defmodule Zippiker.Accounts.Permission do
  use Ash.Resource,
    otp_app: :zippiker,
    domain: Zippiker.Accounts,
    data_layer: AshPostgres.DataLayer


    postgres do
      repo Zippiker.Repo
      table "permissions"
    end

    actions do
      default_accept [:action, :resource]
      defaults [:create, :read, :update, :destroy ]
    end

    attributes do
      uuid_primary_key :id
      attribute :action, :string, allow_nil?: false
      attribute :resource, :string, allow_nil?: false

      timestamps()
    end
end