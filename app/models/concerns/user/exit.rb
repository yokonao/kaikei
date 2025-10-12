class User::Exit
  def initialize(user, company)
    @user = user
    @company = company
  end

  def run
    Membership.where(user_id: @user.id, company_id: @company.id).delete_all
  end

  def exitable?
    # TODO: 事業所からの脱退が可能かどうかを制御する
    true
  end
end
