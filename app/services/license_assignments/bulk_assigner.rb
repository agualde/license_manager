# frozen_string_literal: true

module LicenseAssignments
  class BulkAssigner
    attr_reader :errors

    def initialize(account:, user_ids:, product_ids:)
      @account = account
      @user_ids = user_ids
      @product_ids = product_ids
      @errors = []
    end

    def call
      return false unless valid_params?

      ApplicationRecord.transaction do
        create_assignments
      end

      @errors.empty?
    end

    private

    def valid_params?
      @user_ids.present? && @product_ids.present?
    end

    def create_assignments
      @user_ids.each do |user_id|
        next if user_id.blank?

        @product_ids.each do |product_id|
          next if product_id.blank?

          create_single_assignment(user_id, product_id)
        end
      end
    end

    def create_single_assignment(user_id, product_id)
      assigner = LicenseAssigner.new(
        account: @account,
        user_id: user_id,
        product_id: product_id
      )

      unless assigner.call
        @errors << assigner.error
      end
    end
  end
end
