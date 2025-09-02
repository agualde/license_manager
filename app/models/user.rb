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
class User < ApplicationRecord
  belongs_to :account
  has_many :license_assignments, dependent: :destroy
  has_many :products, through: :license_assignments

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def has_license_for_product?(product)
    license_assignments.exists?(product: product)
  end

  def license_count
    license_assignments&.count
  end
end
