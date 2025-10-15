class MembersController < ApplicationController
  def index
    company = target_company
    @members = User.includes(:memberships).where("memberships.company_id": company.id)
    @inviting_members = Invitation.where(company_id: company.id).
                                   reject { |iv| @members.any? { |m| m.email_address == iv.email_address } }
  end

  def create
    company = target_company
    email_address = params[:email_address]

    iv = Invitation.find_or_initialize_by(email_address: email_address, company: company) do |iv|
      iv.inviter_email_address = Current.user.email_address
    end

    if iv.persisted? || iv.save
      token = iv.generate_token_for(:invitation)
      # 生成したトークンから有効期限を取得する方法がわからないので推定値を利用する
      # TODO: よりよい方法がないか調査する
      token_expires_at = Time.current + Invitation::INVITATION_TOKEN_EXPIRES_IN
      # NOTE: リソースの特定は token で行うので id はダミー値をセットする
      url = invitation_url(SecureRandom.uuid, token: token)

      InvitationMailer.invite(iv, url, token_expires_at).deliver_later
      notice = "#{email_address} に招待メールを送信しました"
    else
      alert = iv.errors.full_messages.join(", ")
    end

    redirect_to company_members_path, notice: notice, alert: alert
  end

  def destroy
    if params[:myself] == "true"
      # 事業所から脱退（= 自分自身のメンバーシップを削除）
      target_user = User.where(id: Current.user&.id).find(params[:id])
      target_user.exit!(target_company)

      redirect_to companies_path, notice: "事業所（#{target_company.name}）から脱退しました。"
    else
      # 他のユーザーのメンバーシップを剥奪する。対象のメンバーが招待中か否かで処理が分岐する
      if params[:inviting] == "true"
        invitation_id = params[:id].try(:to_i)
        Invitation.destroy_by(id: invitation_id, company_id: target_company.id)
        notice = "#{params[:email_address]} の招待をキャンセルしました"
      else
        target_user_id = params[:id].try(:to_i)
        if Current.user.id == target_user_id
          alert = "自分のアクセス権を剥奪することはできません"
        else
          Membership.destroy_by(user_id: target_user_id, company_id: target_company.id)
          notice = "メンバーの事業所へのアクセス権を剥奪しました"
        end
      end

      redirect_to company_members_path, notice: notice, alert: alert
    end
  end
end
