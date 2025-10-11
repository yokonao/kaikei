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
      side: 'debit'
    )

    # Pre-assertions
    assert company.persisted?
    assert_not_empty Membership.where(company_id: company.id)
    assert_not_empty JournalEntry.where(company_id: company.id)
    assert_not_empty FinancialClosing.where(company_id: company.id)
    assert_not_empty BalanceForward.where(company_id: company.id)

    # Action
    incineration = Company::Incineration.new(company)
    incineration.run

    # Post-assertions
    assert company.destroyed?
    assert_empty Membership.where(company_id: company.id)
    assert_empty JournalEntry.where(company_id: company.id)
    assert_empty FinancialClosing.where(company_id: company.id)
    assert_empty BalanceForward.where(company_id: company.id)
  end
end
