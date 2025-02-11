defmodule Zippiker.Support.Representative do
  use Ash.Resource,
    otp_app: :zippiker,
    domain: Zippiker.Support,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "representatives"
    repo Zippiker.Repo
  end

  actions do
    defaults [:read, create: [:name]]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end
  end

  relationships do
    has_many :tickets, Zippiker.Support.Ticket do
      public? true
    end
  end
end
