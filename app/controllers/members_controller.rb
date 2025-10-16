class MembersController < ApplicationController
  before_action :set_member, only: %i[ destroy ]

  def index
    company = target_company
    @members = Member.all(company)
  end

  def create
    company = target_company
    email_address = params[:email_address]

    invitation = company.invitations.build(email_address: email_address, inviter_email_address: Current.user.email_address)
    if invitation.save
      invitation.send_mail
      redirect_to company_members_path, notice: "#{email_address} に招待メールを送信しました"
    else
      redirect_to company_members_path, alert: invitation.errors.full_messages.join(", ")
    end
  end

  def destroy
    params[:myself] == "true" ? destroy_myself : destroy_other
  end

  private

  # 事業所から脱退（= 自分自身のメンバーシップを削除）
  def destroy_myself
    target_user = @member.user
    raise ActionController::BadRequest, "自分以外のユーザーを事業所から脱退させることはできません。" if Current.user != target_user

    target_user.exit!(target_company)
    redirect_to companies_path, notice: "事業所（#{target_company.name}）から脱退しました。"
  end

  # 他のユーザーを事業所から外す
  def destroy_other
    raise ActionController::BadRequest, "自分のアクセス権を剥奪することはできません" if Current.user.id == @member.user_id

    @member.destroy!
    if @member.inviting?
      redirect_to company_members_path notice: "#{@member.email_address} の招待をキャンセルしました"
    else
      redirect_to company_members_path, notice: "#{@member.email_address} の事業所へのアクセス権を剥奪しました"
    end
  end

  def set_member
    @member = Member.find(target_company, params[:id])
  end
end
