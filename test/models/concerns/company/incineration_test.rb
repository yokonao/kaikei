require "test_helper"

class Company::IncinerationTest < ActiveSupport::TestCase
  test "#run" do
    # Setup
    company = Company.create!(name: "Test Company for Incineration")
    user = users(:one)
    Membership.create!(company: company, user: user)

    journal_entry = company.journal_entries.create!(
      entry_date: "2023-10-11",
      summary: "Test Entry",
      journal_entry_lines_attributes: [
        { account: accounts(:sales), amount: 1000, side: "debit" },
        { account: accounts(:cash), amount: 1000, side: "credit" }
      ]
    )

    financial_closing = company.financial_closings.create!(
      start_date: "2023-04-01",
      end_date: "2024-03-31",
      phase: :done
    )

    company.balance_forwards.create!(
      financial_closing: financial_closing,
      closing_date: "2024-03-31",
      account: accounts(:cash),
      amount: 1000,
      side: "debit"
    )

    # All models related to the company should be deleted
    Rails.application.eager_load!
    models_to_delete = ApplicationRecord.descendants.
                                         reject(&:abstract_class?).
                                         reject { |model| model == Session }. # Company が削除されることによって既存の Session は当該事業所にアクセス不可になるので削除する必要なし
                                         select { |model| model.column_names.include?("company_id") }

    # Pre-assertions
    assert company.persisted?
    models_to_delete.each { |model| assert_not_empty model.where(company_id: company.id).to_a, "#{model} should not be empty" }

    # Action
    incineration = Company::Incineration.new(company)
    incineration.run

    # Post-assertions
    assert company.destroyed?
    models_to_delete.each { |model| assert_empty model.where(company_id: company.id).to_a, "#{model} should be empty" }
  end
end
