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
require "rails_helper"

RSpec.describe Product, type: :model do
  describe 'validations' do
    subject { build(:product) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "associations" do
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:accounts).through(:subscriptions) }
    it { should have_many(:license_assignments).dependent(:destroy) }
    it { should have_many(:users).through(:license_assignments) }
  end

  describe "dependent destroy behavior" do
    let(:product) { create(:product) }
    let(:account) { create(:account) }
    let(:user) { create(:user, account: account) }

    before do
      create(:subscription, account: account, product: product)
      create(:license_assignment, account: account, user: user, product: product)
    end

    it "destroys associated subscriptions when product is destroyed" do
      expect { product.destroy }.to change { Subscription.count }.by(-1)
    end

    it "destroys associated license assignments when product is destroyed" do
      expect { product.destroy }.to change { LicenseAssignment.count }.by(-1)
    end
  end
end
