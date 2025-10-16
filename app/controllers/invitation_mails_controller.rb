class InvitationMailsController < ApplicationController
  before_action :set_member, only: %i[ create ]

  def create
    raise ActionController::BadRequest, "招待中でないメンバーに招待メールを送信することはできません" unless @member.inviting?

    @member.invitation.send_mail
    redirect_to company_members_path, notice: "#{@member.email_address} に招待メールを送信しました"
  end

  private

  def set_member
    @member = Member.find(target_company, params[:member_id])
  end
end
