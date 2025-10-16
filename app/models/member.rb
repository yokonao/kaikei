# 事業所に所属するメンバーを表現するモデル
#
# === 種別 ===
# 事業所に所属するメンバーは以下の2つがある
# 1. 当該事業所の Membership を持っているユーザー
# 2. 当該事業所に招待されているメールアドレス
#
# 1. の場合、Member の物理的実体は Membership と User のレコードであり、2の場合は物理的実体は Invitation である
#
# === ID の規約 ===
# 種別1 の場合、id は `MEM-123` のようになる。
# 123 は Membership の id (PRIMARY KEY) である。
#
# 一方、種別2 の場合、id は `INV-123` のようになる。
# 123 は Invitation の id (PRIMARY KEY) である。
class Member
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :string
  attr_accessor :company, :membership, :user, :invitation
  attribute :email_address, :string
  attribute :inviting, :boolean, default: false

  def user_id
    self.user&.id
  end

  # @param type [Symbol] :membership または :invitation それ以外の値は invalid となる
  # @param id [Integer] Membership または Invitation の id
  # @return [String]
  def self.id(type, id)
    case type
    when :membership
      "MEM-#{id}"
    when :invitation
      "INV-#{id}"
    else
      raise "Invalid member type: #{type}"
    end
  end

  # @param company [Company]
  # @return [Array<Member>]
  def self.all(company)
    memberships = company.memberships.includes(:user).map { |membership| from_membership(membership) }
    invitations = company.invitations.map { |invitation| from_invitation(invitation) }
    memberships + invitations
  end

  # @param company [Company]
  # @param id [String]
  # @return [Member]
  def self.find(company, id)
    type, primary_key = id.split("-")
    case type
    when "MEM"
      membership = company.memberships.includes(:user).find(primary_key)
      from_membership(membership)
    when "INV"
      invitation = company.invitations.find(primary_key)
      from_invitation(invitation)
    else
      raise ActiveRecord::RecordNotFound, "Invalid member id: #{id}"
    end
  end

  def self.from_membership(membership)
    new(
      id: id(:membership, membership.id),
      company: membership.company,
      membership: membership,
      user: membership.user,
      email_address: membership.user.email_address,
    )
  end

  def self.from_invitation(invitation)
    new(
      id: id(:invitation, invitation.id),
      company: invitation.company,
      invitation: invitation,
      email_address: invitation.email_address,
      inviting: true
    )
  end

  def destroy!
    if inviting
      invitation.destroy!
    else
      membership.destroy!
    end
  end

  def inviting?
    inviting
  end
end
