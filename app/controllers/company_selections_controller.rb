class CompanySelectionsController < ApplicationController
  allow_no_company_access only: %i[ create ]

  def create
    company = Current.user.companies.find_by(id: params[:company_id])
    select_company company

    redirect_to after_authentication_url
  end
end
