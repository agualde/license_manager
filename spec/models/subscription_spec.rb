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
require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe 'validations' do
    it 'validates uniqueness of product per account' do
      existing = create(:subscription)
      duplicate = build(:subscription, account: existing.account, product: existing.product)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:product_id]).to include('already has a subscription for this account')
    end
  end

  describe "associations" do
    it { should belong_to(:account) }
    it { should belong_to(:product) }
  end

  describe "scopes" do
    let!(:active_subscription) { create(:subscription, expires_at: 1.month.from_now) }
    let!(:expired_subscription) { create(:subscription, expires_at: 1.day.ago) }

    describe ".active" do
      it "returns only active subscriptions" do
        expect(Subscription.active).to include(active_subscription)
        expect(Subscription.active).not_to include(expired_subscription)
      end
    end
  end

  describe "#active?" do
    context "when expires_at is in the future" do
      let(:subscription) { build(:subscription, expires_at: 1.day.from_now) }

      it "returns true" do
        expect(subscription.active?).to be true
      end
    end

    context "when expires_at is in the past" do
      let(:subscription) { build(:subscription, expires_at: 1.day.ago) }

      it "returns false" do
        expect(subscription.active?).to be false
      end
    end
  end

  describe "#available_licenses" do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let!(:subscription) do
      create(:subscription,
             account: account,
             product: product,
             number_of_licenses: 5,
             issued_at: 1.day.ago,
             expires_at: 1.month.from_now)
    end

    context "when subscription is active with no assignments" do
      it "returns the total number of licenses" do
        expect(subscription.available_licenses).to eq(5)
      end
    end

    context 'when subscription is active with some assignments' do
      before do
        users = create_list(:user, 2, account: account)
        users.each do |user|
          create(:license_assignment, account: account, user: user, product: product)
        end
      end

      it 'returns the remaining licenses' do
        expect(subscription.available_licenses).to eq(3)
      end
    end

    context "when subscription is expired" do
      let(:subscription) do
        create(:subscription,
               account: account,
               product: product,
               number_of_licenses: 5,
               expires_at: 1.day.ago)
      end

      it "returns 0" do
        expect(subscription.available_licenses).to eq(0)
      end
    end
  end

  describe '#used_licenses_count' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    let!(:subscription) do
      create(:subscription,
             account: account,
             product: product,
             issued_at: 1.day.ago,
             expires_at: 1.month.from_now)
    end

    before do
      users = create_list(:user, 3, account: account)
      users.each do |user|
        create(:license_assignment, account: account, user: user, product: product)
      end
    end

    it 'returns the correct count of used licenses' do
      expect(subscription.used_licenses_count).to eq(3)
    end
  end
end
