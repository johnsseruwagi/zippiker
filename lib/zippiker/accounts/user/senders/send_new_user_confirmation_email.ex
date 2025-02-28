defmodule Zippiker.Accounts.User.Senders.SendNewUserConfirmationEmail do
  @moduledoc """
  Sends an email for a new user to confirm their email address.
  """

  use AshAuthentication.Sender
  use ZippikerWeb, :verified_routes

  import Swoosh.Email

  alias Zippiker.Mailer

  @impl true
  def send(user, token, _) do
    new()
    # TODO: Replace with your email
    |> from({"noreply", "noreply@example.com"})
    |> to(to_string(user.email))
    |> subject("Confirm your email address")
    |> html_body(body(token: token))
    |> Mailer.deliver!()
  end

  defp body(params) do
    url = url(~p"/auth/user/confirm_new_user?#{[confirm: params[:token]]}")

    """
    <p>Click this link to confirm your email:</p>
    <p><a href="#{url}">#{url}</a></p>
    """
  end
end
