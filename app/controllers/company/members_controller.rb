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
    # 生成したトークンから有効期限を取得する方法がわからないので推定値を利用する
    # TODO: よりよい方法がないか調査する
    token_expires_at = Time.current + Invitation::INVITATION_TOKEN_EXPIRES_IN

    InvitationMailer.invite(iv, invitation_url(token: token), token_expires_at).deliver_later

    redirect_to company_members_path, notice: "#{email_address} に招待メールを送信しました。"
  end
end
