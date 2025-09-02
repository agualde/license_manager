# frozen_string_literal: true

module LicenseAssignments
  class BulkUnassigner
    attr_reader :error

    def initialize(account:, user_ids:, product_ids:)
      @account = account
      @user_ids = user_ids
      @product_ids = product_ids
      @error = nil
    end

    def call
      ApplicationRecord.transaction do
        unassign_licenses
      end
    rescue StandardError => e
      @error = "Failed to unassign licenses: #{e.message}"
      false
    end

    private

    def unassign_licenses
      return set_error("No user IDs provided") if @user_ids.empty?
      return set_error("No product IDs provided") if @product_ids.empty?

      deleted_count = relation.delete_all

      if deleted_count > 0
        true
      else
        set_error("No matching license assignments found to unassign")
      end
    end

    def relation
      LicenseAssignment.where(
        account_id: @account.id,
        user_id:    @user_ids,
        product_id: @product_ids
      )
    end

    def set_error(message)
      @error = message
      false
    end
  end
end
