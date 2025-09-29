class CompaniesController < ApplicationController
  allow_no_company_access only: %i[ index new create ]

  def index
    @user = Current.user
    @companies = @user.companies
    @current_company = Current.company
  end

  def new
    @user = Current.user
    @company = Company.new
  end

  def create
    user = Current.user
    company = Company.new(company_params)

    render :new, status: :unprocessable_content unless company.valid?

    ActiveRecord::Base.transaction do
      company.save!
      Membership.create!(user: user, company: company)
    end

    select_company company
    redirect_to after_authentication_url
  end

  private

  def company_params
    params.expect(company: [ :name ])
  end
end
