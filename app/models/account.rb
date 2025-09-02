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
class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :license_assignments, dependent: :destroy
  has_many :products, through: :subscriptions

  validates :name, presence: true, uniqueness: true

  def available_licenses_for_product(product)
    subscription = subscriptions.find_by(product: product)
    return 0 unless subscription&.active?

    total_licenses = subscription.number_of_licenses
    used_licenses = license_assignments.where(product: product).count
    total_licenses - used_licenses
  end

  def subscription_for_product(product)
    subscriptions.find_by(product: product)
  end
end
