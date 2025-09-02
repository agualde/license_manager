# frozen_string_literal: true

module LicenseAssignments
  class LicenseAssigner
    attr_reader :error

    def initialize(account:, user_id:, product_id:)
      @account = account
      @user_id = user_id
      @product_id = product_id
      @error = nil
    end

    def call
      user = @account.users.find(@user_id)
      product = Product.find(@product_id)

      assignment = @account.license_assignments.build(
        user: user,
        product: product
      )

      if assignment.save
        true
      else
        @error = "#{user.name} - #{product.name}: #{assignment.errors.full_messages.join(', ')}"
        false
      end
    rescue ActiveRecord::RecordNotFound => e
      @error = "Record not found: #{e.message}"
      false
    end
  end
end
