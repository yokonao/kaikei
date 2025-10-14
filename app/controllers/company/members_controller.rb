class Company::MembersController < ApplicationController
  def index
    company = Current.company
    @members = User.includes(:memberships).where("memberships.company_id": company.id)
    @inviting_members = Invitation.where(company_id: company.id).
                                   group(:email_address).
                                   reject { |iv| @members.any? { |m| m.email_address == iv.email_address } }
  end

  def create
    user, company = Current.user, Current.company
    email_address = params[:email_address]

    iv = Invitation.find_or_create_by!(email_address: email_address, company: company) do |iv|
      iv.inviter_email_address = user.email_address
    end
    token = iv.generate_token_for(:invitation)
    # 生成したトークンから有効期限を取得する方法がわからないので推定値を利用する
    # TODO: よりよい方法がないか調査する
    token_expires_at = Time.current + Invitation::INVITATION_TOKEN_EXPIRES_IN

    # NOTE: リソースの特定は token で行うので id はダミー値をセットする
    url = invitation_url(SecureRandom.uuid, token: token)

    InvitationMailer.invite(iv, url, token_expires_at).deliver_later

    redirect_to company_members_path, notice: "#{email_address} に招待メールを送信しました。"
  end

  def destroy
    user, company = Current.user, Current.company
    if params[:inviting] == "true"
      Invitation.where(email_address: params[:email_address], company_id: company.id).destroy_all
      notice = "#{params[:email_address]} の招待をキャンセルしました"
    else
      target_user_id = params[:user_id].try(:to_i)
      if user.id == target_user_id
        alert = "自分のアクセス権を剥奪することはできません"
      else
        Membership.where(user_id: params[:user_id], company_id: company.id).destroy_all
        notice = "メンバーの事業所へのアクセス権を剥奪しました"
      end
    end


    redirect_to company_members_path, notice: notice, alert: alert
  end
end
