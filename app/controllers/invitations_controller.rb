class InvitationsController < ApplicationController
  allow_unauthenticated_access only: %i[ show update ]
  before_action :set_invitation, only: %i[ show update ]

  def show
    resume_session # TODO: ログイン状態かどうか確かめるために必要だが不要にしたい

    @current_user = Current.user

    @existing_user = User.find_by(email_address: @invitation.email_address)
    @email_address_mismatch = @current_user.present? && @invitation.email_address != @current_user.email_address
    @membership_already_exists = @existing_user.present? && Membership.where(user_id: @existing_user.id, company_id: @invitation.company_id).exists?
  end

  def update
    Invitation.accept!(@invitation)

    if user = @invitation.user
      terminate_session
      start_new_session_for user, company: @invitation.company
    end

    redirect_to companies_path
  end

  private

  def set_invitation
    # NOTE: リソースの特定は token で行うので id はダミー値がセットされている
    @dummy_id = params[:id]
    @invitation_token = params[:token]
    @invitation = Invitation.find_by_token_for(:invitation, @invitation_token)
    raise ActiveRecord::RecordNotFound if @invitation.blank?
  end
end
