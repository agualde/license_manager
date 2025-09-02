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
require "rails_helper"

RSpec.describe Account, type: :model do
  describe 'validations' do
    subject { build(:account) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "associations" do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:license_assignments).dependent(:destroy) }
    it { should have_many(:products).through(:subscriptions) }
  end

  describe "#available_licenses_for_product" do
    let(:account) { create(:account) }
    let(:product) { create(:product) }

    context "with no subscription" do
      it "returns 0" do
        expect(account.available_licenses_for_product(product)).to eq(0)
      end
    end

    context "with expired subscription" do
      let!(:subscription) do
        create(:subscription,
               account: account,
               product: product,
               expires_at: 1.day.ago,
               number_of_licenses: 10)
      end

      it "returns 0" do
        expect(account.available_licenses_for_product(product)).to eq(0)
      end
    end

    context "with active subscription and no assignments" do
      let!(:subscription) do
        create(:subscription,
               account: account,
               product: product,
               number_of_licenses: 10)
      end

      it "returns the full number of licenses" do
        expect(account.available_licenses_for_product(product)).to eq(10)
      end
    end

    context "with active subscription and some assignments" do
      let!(:subscription) do
        create(:subscription,
               account: account,
               product: product,
               number_of_licenses: 10)
      end

      let!(:users) { create_list(:user, 3, account: account) }

      before do
        users.each do |user|
          create(:license_assignment, account: account, user: user, product: product)
        end
      end

      it "returns the remaining available licenses" do
        expect(account.available_licenses_for_product(product)).to eq(7)
      end
    end
  end

  describe "#subscription_for_product" do
    let(:account) { create(:account) }
    let(:product) { create(:product) }

    context "when subscription exists" do
      let!(:subscription) { create(:subscription, account: account, product: product) }

      it "returns the subscription" do
        expect(account.subscription_for_product(product)).to eq(subscription)
      end
    end

    context "when no subscription exists" do
      it "returns nil" do
        expect(account.subscription_for_product(product)).to be_nil
      end
    end
  end
end
