class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  def company
    return nil unless user

    user.companies.find_by(id: session.company_id)
  end
end
