defmodule CategoryCase do
  alias Zippiker.KnowledgeBase.Category

  @doc """
  Get a single category from the database. If none exists,
  insert categories and return the first one.
  """
  def get_category do
    case Ash.read_first(Category) do
      {:ok, nil} -> create_categories() |> Enum.at(0)
      {:ok, category} -> category
    end
  end

  @doc """
  Get a list of categories. If none exist in the database,
  insert them and return the list.
  """
  def get_categories do
    case Ash.read(Category) do
      {:ok, []} -> create_categories()
      {:ok, categories} -> categories
    end
  end

  @doc """
  Insert categories into the database.
  """
  def create_categories do
    attrs = [
      %{
        name: "Account and Login",
        slug: "account-login",
        description: "Help with account creation, login issues, and profile management"
      },
      %{
        name: "Billing and Payments",
        slug: "billing-payments",
        description: "Assistance with invoices, subscription plans, and payment issues"
      },
      %{
        name: "HR Management",
        slug: "hr-management",
        description: "Guides and support for employee onboarding, time-off, and payroll"
      },
      %{
        name: "Accounting and Finance",
        slug: "accounting-finance",
        description: "Help with financial reports, budgeting, and expense tracking"
      },
      %{
        name: "Inventory Management",
        slug: "inventory-management",
        description: "Support for stock tracking, warehouse management, and orders"
      },
      %{
        name: "Production and Manufacturing",
        slug: "production-manufacturing",
        description: "Guides for managing production schedules, resources, and outputs"
      },
      %{
        name: "Approvals and Workflows",
        slug: "approvals-workflows",
        description: "Help with configuring multi-step approvals and automated workflows"
      },
      %{
        name: "Reporting and Analytics",
        slug: "reporting-analytics",
        description: "Insights on generating and interpreting data-driven reports"
      },
      %{
        name: "System Setup and Integration",
        slug: "system-setup-integration",
        description: "Support for initial setup and integrating Zippiker with other tools"
      },
      %{
        name: "General Support",
        slug: "general-support",
        description: "Get answers to general questions and troubleshooting tips"
      }
    ]

    Ash.Seed.seed!(Category, attrs)
  end
end