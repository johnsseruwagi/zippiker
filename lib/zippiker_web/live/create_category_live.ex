defmodule ZippikerWeb.CreateCategoryLive do
  @moduledoc """
  Liveview module to create a new category into the database
  """

  use ZippikerWeb, :live_view

  def render(assigns) do
    ~H"""
    <%!-- Display link to take user back to category list --%>
    <.back navigate={~p"/categories"}>{gettext("Back to categories")}</.back>

    <%!-- Typical simple form from core_components --%>
    <ZippikerWeb.CategoryFormComponent.form />
    """
  end


end