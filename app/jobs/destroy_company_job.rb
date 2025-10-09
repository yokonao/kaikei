class DestroyCompanyJob < ApplicationJob
  queue_as :default

  def perform(company_id:)
    company = Company.find(company_id)
    company.incinerate!
  end
end
