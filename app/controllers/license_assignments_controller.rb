class LicenseAssignmentsController < ApplicationController
  before_action :load_index_data, only: [ :index ]

  def index; end

  def create
    assigner = LicenseAssignments::BulkAssigner.new(
      account:,
      user_ids: params[:user_ids],
      product_ids: params[:product_ids]
    )

    if assigner.call
      redirect_to account_license_assignments_path(account), notice: "Licenses assigned successfully."
    else
      flash.now[:alert] = error_message(assigner)
      load_index_data
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    license_assignment = account.license_assignments.find(params[:id])
    license_assignment.destroy
    redirect_to account_license_assignments_path(account), notice: "License unassigned successfully."
  end

  def bulk_destroy
    unassigner = LicenseAssignments::BulkUnassigner.new(
      account:,
      user_ids: params[:user_ids],
      product_ids: params[:product_ids]
    )

    if unassigner.call
      redirect_to account_license_assignments_path(account), notice: "Licenses unassigned successfully."
    else
      flash.now[:alert] = "Unable to unassign licenses. Please try again."
      load_index_data
      render :index, status: :unprocessable_entity
    end
  end

  private

  def account
    @account ||= Account.find(params[:account_id])
  end

  def load_index_data
    @products_with_licenses = products_with_licenses_data
    @users = account.users.order(:name)
    @assigned_licenses = account.license_assignments.includes(:product, :user)
  end

  def products_with_licenses_data
    account.subscriptions.active.includes(:product).map do |subscription|
      {
        product: subscription.product,
        total_licenses: subscription.number_of_licenses,
        available_licenses: subscription.available_licenses,
        used_licenses: subscription.used_licenses_count
      }
    end
  end

  def error_message(assigner)
    return "Please select both users and products." unless assigner.errors.any?

    assigner.errors.join("; ")
  end
end
