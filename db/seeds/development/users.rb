user1 = User.create!(email_address: "test@example.com")
user2 = User.create!(email_address: "test2@example.com")

company1 = Company.create!(name: "テスト事業所1")
company2 = Company.create!(name: "テスト事業所2")
company3 = Company.create!(name: "テスト事業所3")

Membership.create!(user: user1, company: company1)
Membership.create!(user: user1, company: company2)
Membership.create!(user: user1, company: company3)
Membership.create!(user: user2, company: company1)
