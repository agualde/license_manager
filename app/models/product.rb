# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_products_on_name  (name) UNIQUE
#
class Product < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :accounts, through: :subscriptions
  has_many :license_assignments, dependent: :destroy
  has_many :users, through: :license_assignments

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
