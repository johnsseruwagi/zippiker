defmodule Zippiker.Support do
  use Ash.Domain,
    otp_app: :zippiker

  resources do
    resource Zippiker.Support.Ticket
    resource Zippiker.Support.Representative
  end
end
