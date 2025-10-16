class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :company, :membership
end
