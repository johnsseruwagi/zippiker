defmodule Zippiker.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Zippiker.Accounts.User, _opts) do
    Application.fetch_env(:zippiker, :token_signing_secret)
  end
end
