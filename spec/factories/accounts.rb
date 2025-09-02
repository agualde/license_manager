# == Schema Information
#
# Table name: accounts
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_accounts_on_name  (name) UNIQUE
#
FactoryBot.define do
  factory :account do
    name { Faker::Company.name }
  end
end
