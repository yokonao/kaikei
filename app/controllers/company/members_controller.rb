class Company::MembersController < ApplicationController
  def index
    company = Current.company
    @members = User.includes(:memberships).where("memberships.company_id": company.id).page(params[:page]).per(100)
  end

  def create
    email_address = params[:email_address]

    Rails.logger.debug "TODO: メンバーの追加処理を実装する"

    redirect_to company_members_path
  end
end
