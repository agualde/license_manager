# frozen_string_literal: true

module LicenseAssignments
  class BulkUnassigner
    def initialize(account:, user_ids:, product_ids:)
      @account = account
      @user_ids = user_ids
      @product_ids = product_ids
    end

    def call
      ApplicationRecord.transaction do
        unassign_licenses
      end
    end

    private

    def unassign_licenses
      return false if @user_ids.empty? || @product_ids.empty?

      relation.delete_all
      true
    end

    def relation
      LicenseAssignment.where(
        account_id: @account.id,
        user_id:    @user_ids,
        product_id: @product_ids
      )
    end
  end
end
