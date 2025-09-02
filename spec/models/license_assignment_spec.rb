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
require "rails_helper"

RSpec.describe LicenseAssignment, type: :model do
  describe "validations" do
    let(:account) { create(:account) }
    let(:user) { create(:user, account: account) }
    let(:product) { create(:product) }
    let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 2) }

    describe 'uniqueness validation' do
      let(:account) { create(:account) }
      let(:user) { create(:user, account: account) }
      let(:product) { create(:product) }
      let!(:subscription) { create(:subscription, account: account, product: product) }
      let!(:existing) { create(:license_assignment, account: account, user: user, product: product) }

      it 'prevents duplicate assignments for same user and product' do
        duplicate = build(:license_assignment, account: account, user: user, product: product)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('already has a license for this product')
      end
    end

    describe "user_belongs_to_account validation" do
      it "is invalid when user belongs to different account" do
        other_account = create(:account)
        other_user = create(:user, account: other_account)

        assignment = build(:license_assignment, account: account, user: other_user, product: product)
        expect(assignment).not_to be_valid
        expect(assignment.errors[:user]).to include("must belong to the specified account")
      end

      it "is valid when user belongs to same account" do
        assignment = build(:license_assignment, account: account, user: user, product: product)
        expect(assignment).to be_valid
      end
    end

    describe "account_has_subscription_for_product validation" do
      it "is invalid when account has no subscription for product" do
        other_product = create(:product)
        assignment = build(:license_assignment, account: account, user: user, product: other_product)

        expect(assignment).not_to be_valid
        expect(assignment.errors[:product]).to include("account doesn't have an active subscription")
      end

      it "is invalid when subscription is expired" do
        subscription.update!(expires_at: 1.day.ago)
        assignment = build(:license_assignment, account: account, user: user, product: product)

        expect(assignment).not_to be_valid
        expect(assignment.errors[:product]).to include("account doesn't have an active subscription")
      end

      it "is valid when account has active subscription" do
        assignment = build(:license_assignment, account: account, user: user, product: product)
        expect(assignment).to be_valid
      end
    end

    describe "licenses_available validation" do
      before do
        users = create_list(:user, 2, account: account)
        users.each do |u|
          create(:license_assignment, account: account, user: u, product: product)
        end
      end

      it "is invalid when no licenses are available" do
        new_user = create(:user, account: account)
        assignment = build(:license_assignment, account: account, user: new_user, product: product)

        expect(assignment).not_to be_valid
        expect(assignment.errors[:base]).to include("No licenses available for this product")
      end
    end

    describe "duplicate assignment prevention" do
      let!(:existing_assignment) { create(:license_assignment, account: account, user: user, product: product) }

      it "prevents duplicate assignments for same user and product" do
        duplicate_assignment = build(:license_assignment, account: account, user: user, product: product)

        expect(duplicate_assignment).not_to be_valid
        expect(duplicate_assignment.errors[:user_id]).to be_present
      end
    end
  end

  describe "associations" do
    it { should belong_to(:account) }
    it { should belong_to(:user) }
    it { should belong_to(:product) }
  end

  describe "complex scenarios" do
    let(:account) { create(:account) }
    let(:users) { create_list(:user, 3, account: account) }
    let(:product) { create(:product) }
    let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 2) }

    context "when trying to assign more licenses than available" do
      before do
        users.first(2).each do |user|
          create(:license_assignment, account: account, user: user, product: product)
        end
      end

      it "prevents assignment to third user" do
        assignment = build(:license_assignment, account: account, user: users.last, product: product)

        expect(assignment).not_to be_valid
        expect(assignment.errors[:base]).to include("No licenses available for this product")
      end
    end

    context 'when subscription expires after assignment' do
      let!(:assignment) { create(:license_assignment, account: account, user: users.first, product: product) }

      it 'existing assignment becomes invalid when subscription expires' do
        subscription.update!(expires_at: 1.day.ago)

        expect(assignment.reload).not_to be_valid
        expect(assignment.errors[:product]).to include("account doesn't have an active subscription")
      end
    end
  end
end
