defmodule ZippikerWeb.EditCategoryLive do
  @moduledoc """
  Edits an existing categroy
  """
  use ZippikerWeb, :live_view

  @doc """
  1. Retrieves category_id from the route parameter
  2. Assign it in the socket
  3. Assign form in the socket
  """
  def mount(%{"category_id" => category_id} = _params, _session, socket) do
    socket
    |> assign(:category_id, category_id)
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <%!-- Display link to take user back to category list --%>
    <.back navigate={~p"/categories"}>{gettext("Back to categories")}</.back>
    <ZippikerWeb.CategoryFormComponent.form category_id={@category_id} actor={@current_user} />
    """
  end
end
