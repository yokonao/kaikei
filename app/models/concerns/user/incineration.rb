class User::Incineration
  def initialize(user)
    @user = user
  end

  def run
    Membership.where(user_id: @user.id).destroy_all
    Session.where(user_id: @user.id).destroy_all
    @user.user_one_time_password&.destroy!
    @user.user_passkeys.destroy_all

    @user.destroy!
  end
end
