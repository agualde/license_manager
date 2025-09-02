class UsersController < ApplicationController
  before_action :set_account
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = @account.users
  end

  def show
    @license_assignments = @user.license_assignments.includes(:product)
  end

  def new
    @user = @account.users.build
  end

  def create
    @user = @account.users.build(user_params)

    if @user.save
      redirect_to [ @account, @user ], notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to [ @account, @user ], notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to account_users_url(@account), notice: "User was successfully deleted."
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_user
    @user = @account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
