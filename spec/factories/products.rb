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
FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "vLex #{Faker::Address.country} #{n}" }
    description { Faker::Lorem.paragraph }
  end
end
