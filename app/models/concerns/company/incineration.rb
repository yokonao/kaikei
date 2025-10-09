class Company::Incineration
  def initialize(company)
    @company = company
  end

  def run
    # TODO:
    # rm balance_forwards
    # rm companies
    # rm financial_closings
    # rm journal_entries
    # rm journal_entry_lines
    # rm memberships

    puts "Incinerating the company (id: #{@company.id})"
  end
end
