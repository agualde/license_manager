# == Schema Information
#
# Table name: subscriptions
#
#  id                 :bigint           not null, primary key
#  expires_at         :datetime         not null
#  issued_at          :datetime         not null
#  number_of_licenses :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  product_id         :bigint           not null
#
# Indexes
#
#  index_subscriptions_on_account_id                 (account_id)
#  index_subscriptions_on_account_id_and_product_id  (account_id,product_id) UNIQUE
#  index_subscriptions_on_product_id                 (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (product_id => products.id)
#
FactoryBot.define do
  factory :subscription do
    account
    product
    number_of_licenses { 10 }
    issued_at { 1.month.ago }
    expires_at { 11.months.from_now }
  end
end
