# == Schema Information
#
# Table name: license_assignments
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  product_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_license_assignments_on_account_id                 (account_id)
#  index_license_assignments_on_account_id_and_product_id  (account_id,product_id)
#  index_license_assignments_on_product_id                 (product_id)
#  index_license_assignments_on_user_id                    (user_id)
#  index_license_assignments_on_user_id_and_product_id     (user_id,product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#
class LicenseAssignment < ApplicationRecord
  belongs_to :account
  belongs_to :user
  belongs_to :product

  validates :user_id, uniqueness: { scope: [ :account_id, :product_id ],
                                   message: "already has a license for this product" }
  validate :user_belongs_to_account
  validate :account_has_subscription_for_product
  validate :licenses_available

  private

  def user_belongs_to_account
    return unless user && account
    errors.add(:user, "must belong to the specified account") unless user.account == account
  end

  def account_has_subscription_for_product
    return unless account && product
    subscription = account.subscription_for_product(product)
    errors.add(:product, "account doesn't have an active subscription") unless subscription&.active?
  end

  def licenses_available
    return unless account && product
    available = account.available_licenses_for_product(product)
    errors.add(:base, "No licenses available for this product") if available <= 0
  end
end
