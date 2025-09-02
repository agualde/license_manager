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
class Subscription < ApplicationRecord
  belongs_to :account
  belongs_to :product

  validates :number_of_licenses, presence: true, numericality: { greater_than: 0 }
  validates :issued_at, presence: true
  validates :expires_at, presence: true
  validate :expires_at_after_issued_at
  validates :product_id, uniqueness: { scope: :account_id, message: "already has a subscription for this account" }

  scope :active, -> { where("expires_at > ?", Time.current) }

  def active?
    expires_at > Time.current
  end

  def available_licenses
    return 0 unless active?

    number_of_licenses - used_licenses_count
  end

  def used_licenses_count
    account.license_assignments.where(product: product).count
  end

  private

  def expires_at_after_issued_at
    return unless issued_at && expires_at

    errors.add(:expires_at, "must be after issue date") if expires_at <= issued_at
  end
end
