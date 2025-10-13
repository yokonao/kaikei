class Company::MembersController < ApplicationController
  def index
    company = Current.company
    @members = User.includes(:memberships).where("memberships.company_id": company.id).page(params[:page]).per(100)
  end

  def create
    user, company = Current.user, Current.company
    email_address = params[:email_address]

    iv = Invitation.create!(
      email_address: email_address,
      inviter_email_address: user.email_address,
      company: company
    )
    token = iv.generate_token_for(:invitation)

    Rails.logger.debug "TODO: メンバーの追加処理を実装する"
    Rails.logger.debug "token: #{token}"
    Rails.logger.debug "url: #{invitation_url(token: token)}"

    redirect_to company_members_path
  end
end
