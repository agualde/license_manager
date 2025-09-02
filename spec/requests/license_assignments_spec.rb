# spec/requests/license_assignments_spec.rb
require "rails_helper"

RSpec.describe "LicenseAssignments", type: :request do
  let!(:account)  { create(:account) }
  let!(:users)    { create_list(:user, 2, account: account) }
  let!(:products) { create_list(:product, 2) }

  # helper to subscribe this account to all products with ample capacity
  def subscribe_all!(acct:, prods:, seats: 10)
    prods.each { |p| create(:subscription, account: acct, product: p, number_of_licenses: seats) }
  end

  describe "GET /accounts/:account_id/license_assignments" do
    it "200s" do
      get account_license_assignments_path(account)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /accounts/:account_id/license_assignments" do
    before { subscribe_all!(acct: account, prods: products, seats: 10) }

    it "creates all user×product assignments and redirects" do
      expect {
        post account_license_assignments_path(account), params: {
          user_ids: users.map(&:id),
          product_ids: products.map(&:id)
        }
      }.to change { LicenseAssignment.where(account: account).count }.by(4)

      expect(response).to redirect_to(account_license_assignments_path(account))
    end

    it "422s and creates nothing when params missing" do
      expect {
        post account_license_assignments_path(account), params: { user_ids: [] }
      }.not_to change(LicenseAssignment, :count)

      # Rack deprecates :unprocessable_entity symbol—but status code is still 422
      expect(response).to have_http_status(422)
    end

    it "422s and aggregates errors on duplicate (uniqueness validation holds)" do
      create(:license_assignment, account: account, user: users.first, product: products.first)

      expect {
        post account_license_assignments_path(account), params: {
          user_ids: [ users.first.id ],
          product_ids: [ products.first.id ]
        }
      }.not_to change(LicenseAssignment, :count)

      expect(response).to have_http_status(422)
    end

    it "ignores blank ids safely" do
      expect {
        post account_license_assignments_path(account), params: {
          user_ids: [ users.first.id, "" ],
          product_ids: [ products.first.id, "" ]
        }
      }.to change { LicenseAssignment.where(account: account).count }.by(1)

      expect(response).to redirect_to(account_license_assignments_path(account))
    end
  end

  describe "DELETE /accounts/:account_id/license_assignments/:id" do
    before { subscribe_all!(acct: account, prods: products, seats: 10) }

    it "destroys and redirects" do
      la = create(:license_assignment, account: account, user: users.first, product: products.first)

      expect {
        delete account_license_assignment_path(account, la)
      }.to change { LicenseAssignment.exists?(la.id) }.from(true).to(false)

      expect(response).to redirect_to(account_license_assignments_path(account))
    end

    it "scopes to account (404 for foreign assignment)" do
      other_account = create(:account)
      outsider_user = create(:user, account: other_account)
      create(:subscription, account: other_account, product: products.first, number_of_licenses: 10)
      outsider_la = create(:license_assignment, account: other_account, user: outsider_user, product: products.first)

      expect {
        delete account_license_assignment_path(account, outsider_la)
      }.not_to change { LicenseAssignment.exists?(outsider_la.id) }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /accounts/:account_id/license_assignments/bulk_destroy" do
    before do
      subscribe_all!(acct: account, prods: products, seats: 10)
      users.product(products).each do |u, p|
        create(:license_assignment, account: account, user: u, product: p)
      end
    end

    it "destroys selected pairs and redirects" do
      target_user_ids    = [ users.first.id ]
      target_product_ids = products.map(&:id)

      expect {
        delete bulk_destroy_account_license_assignments_path(account), params: {
          user_ids: target_user_ids,
          product_ids: target_product_ids
        }
      }.to change {
        LicenseAssignment.where(account: account, user_id: target_user_ids, product_id: target_product_ids).count
      }.from(2).to(0)

      expect(response).to redirect_to(account_license_assignments_path(account))
    end
  end
end
