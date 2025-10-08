require_relative "seeds/accounts"

if Rails.env.development?
  require_relative "seeds/development/users"
  require_relative "seeds/development/company1_2024"
  require_relative "seeds/development/company1_2025"
end
