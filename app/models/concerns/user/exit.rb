class User::Exit
  include ActiveModel::Validations

  validate :user_belongs_to_company
  validate :user_is_not_last_member_of_company

  def initialize(user, company)
    @user = user
    @company = company
  end

  def run
    validate!
    Membership.where(user_id: @user.id, company_id: @company.id).delete_all
  end

  private

  def user_belongs_to_company
    return if @user.companies.exists?(id: @company.id)

    errors.add(:base, "ユーザーは事業所に所属していません")
  end

  def user_is_not_last_member_of_company
    other_company_members = Membership.where(company_id: @company.id).where.not(user_id: @user.id)
    return if other_company_members.exists?

    errors.add(:base, "事業所の最後のメンバーは脱退できません。代わりに事業所を削除してください")
  end
end
