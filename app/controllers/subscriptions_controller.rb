class SubscriptionsController < ApplicationController
  before_action :set_account
  before_action :set_subscription, only: [ :show, :edit, :update, :destroy ]

  def index
    @subscriptions = @account.subscriptions.includes(:product)
  end

  def show
    @license_assignments = @account.license_assignments.where(product: @subscription.product).includes(:user)
  end

  def new
    @subscription = @account.subscriptions.build
    @products = Product.all
    @available_products = @products - @account.products
  end

  def create
    @subscription = @account.subscriptions.build(subscription_params)

    if @subscription.save
      redirect_to [ @account, @subscription ], notice: "Subscription was successfully created."
    else
      @products = Product.all
      @available_products = @products - @account.products
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.all
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to [ @account, @subscription ], notice: "Subscription was successfully updated."
    else
      @products = Product.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subscription.destroy
    redirect_to account_subscriptions_url(@account), notice: "Subscription was successfully deleted."
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_subscription
    @subscription = @account.subscriptions.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:product_id, :number_of_licenses, :issued_at, :expires_at)
  end
end
