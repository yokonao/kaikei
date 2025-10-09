class Company::Incineration
  def initialize(company)
    @company = company
  end

  def run
    @company.balance_forwards.destroy_all
    @company.financial_closings.destroy_all
    @company.journal_entries.destroy_all
    Membership.where(company_id: @company.id).destroy_all

    @company.destroy!
  end
end
