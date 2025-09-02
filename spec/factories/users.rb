# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#
# Indexes
#
#  index_users_on_account_id            (account_id)
#  index_users_on_account_id_and_email  (account_id,email)
#  index_users_on_email                 (email) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
FactoryBot.define do
  factory :user do
    account
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
  end
end
