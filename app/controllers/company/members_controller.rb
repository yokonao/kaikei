class Company::MembersController < ApplicationController
  def index
    company = Current.company
    @members = User.includes(:memberships).where("memberships.company_id": company.id).page(params[:page]).per(100)
  end
end
