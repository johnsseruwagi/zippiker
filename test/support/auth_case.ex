defmodule AuthCase do

  def login(conn, user) do
    case AshAuthentication.Jwt.token_for_user(user, %{}, domain: Zippiker.Accounts) do
      {:ok, token, _claims} ->
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Plug.Conn.put_session(:user_token, token)

      {:error, reason} ->
      raise "Failed to generate token: #{inspect(reason)}"
    end
  end

  def create_user() do
    Zippiker.Accounts.User
    |> Ash.Seed.seed!(%{email: "nath.tester@example.com"})
  end

end