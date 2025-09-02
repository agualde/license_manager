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
require "rails_helper"

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    it { should validate_uniqueness_of(:email) }
  end

  describe "associations" do
    it { should belong_to(:account) }
    it { should have_many(:license_assignments).dependent(:destroy) }
    it { should have_many(:products).through(:license_assignments) }
  end

  describe "#has_license_for_product?" do
    let(:user) { create(:user) }
    let(:product) { create(:product) }

    context "when user has a license for the product" do
      before do
        create(:subscription, account: user.account, product: product)
        create(:license_assignment, account: user.account, user: user, product: product)
      end

      it "returns true" do
        expect(user.has_license_for_product?(product)).to be true
      end
    end

    context "when user does not have a license for the product" do
      it "returns false" do
        expect(user.has_license_for_product?(product)).to be false
      end
    end
  end

  describe "#license_count" do
    let(:user) { create(:user) }
    let(:products) { create_list(:product, 3) }

    before do
      products.each do |product|
        create(:subscription, account: user.account, product: product)
        create(:license_assignment, account: user.account, user: user, product: product)
      end
    end

    it "returns the correct number of licenses" do
      expect(user.license_count).to eq(3)
    end
  end
end
