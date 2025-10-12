class User::Incineration
  include ActiveModel::Validations

  validate :user_has_no_memberships

  def initialize(user)
    @user = user
  end

  def run
    validate!

    Membership.where(user_id: @user.id).destroy_all
    Session.where(user_id: @user.id).destroy_all
    @user.user_one_time_password&.destroy!
    @user.user_passkeys.destroy_all

    @user.destroy!
  end

  private

  def user_has_no_memberships
    return unless @user.memberships.exists?

    errors.add(:base, "事業所に所属しているユーザーを削除することはできません")
  end
end
