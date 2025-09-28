class CompanySelectionsController < ApplicationController
  allow_no_company_access only: %i[ new create ]

  def new
    @user = Current.user
    @companies = @user.companies
    @current_company = Current.company
  end

  def create
    company = Current.user.companies.find_by(id: params[:company_id])
    select_company company

    redirect_to after_authentication_url
  end
end
