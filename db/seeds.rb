puts "Clearing existing data..."
LicenseAssignment.destroy_all
Subscription.destroy_all
User.destroy_all
Product.destroy_all
Account.destroy_all

puts "Creating sample data..."

# Create accounts
account1 = FactoryBot.create(:account, name: "Best Law Firm")
account2 = FactoryBot.create(:account, name: "Tech Startup Inc")

# Create products
product1 = FactoryBot.create(:product, name: "vLex Colombia", description: "Legal research platform for Colombia")
product2 = FactoryBot.create(:product, name: "vLex Costa Rica", description: "Legal research platform for Costa Rica")
product3 = FactoryBot.create(:product, name: "vLex España", description: "Legal research platform for Spain")

# Create users for Best Law Firm
users_data = [
  "Dean Pendley", "Robin Chesterman", "Angel Faus", "Stu Duff", "Kalam Lais",
  "Rose Higgins", "Nacho Tinoco", "Álvaro Pérez Mompeán", "Eserophe Ovie-Okoro",
  "Guillermo Espindola", "Rory Campbell", "Davide Bonavita"
]

users = users_data.map do |name|
  email = "#{name.downcase.gsub(' ', '.').gsub('á', 'a').gsub('é', 'e')}@bestlaw.com"
  FactoryBot.create(:user, name: name, email: email, account: account1)
end

# Create users for Tech Startup
tech_users = [
  FactoryBot.create(:user, name: "John Smith", email: "john.smith@techstartup.com", account: account2),
  FactoryBot.create(:user, name: "Jane Doe", email: "jane.doe@techstartup.com", account: account2)
]

# Create subscriptions FIRST
FactoryBot.create(:subscription,
  account: account1, product: product1, number_of_licenses: 10,
  issued_at: 1.month.ago, expires_at: 11.months.from_now
)

FactoryBot.create(:subscription,
  account: account1, product: product2, number_of_licenses: 10,
  issued_at: 1.month.ago, expires_at: 11.months.from_now
)

FactoryBot.create(:subscription,
  account: account1, product: product3, number_of_licenses: 10,
  issued_at: 1.month.ago, expires_at: 11.months.from_now
)

FactoryBot.create(:subscription,
  account: account2, product: product1, number_of_licenses: 5,
  issued_at: 2.weeks.ago, expires_at: 10.months.from_now
)

# NOW create license assignments without factory callbacks
# Colombia assignments (5 users)
users.first(5).each do |user|
  LicenseAssignment.create!(account: account1, user: user, product: product1)
end

# Costa Rica assignments (5 users, some overlap)
costa_rica_users = [ users[0], users[1], users[5], users[6], users[7] ]
costa_rica_users.each do |user|
  LicenseAssignment.create!(account: account1, user: user, product: product2)
end

# España has no assignments (matches the design showing 10/10 available)

puts "Created:"
puts "- #{Account.count} accounts"
puts "- #{Product.count} products"
puts "- #{User.count} users"
puts "- #{Subscription.count} subscriptions"
puts "- #{LicenseAssignment.count} license assignments"
