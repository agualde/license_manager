Rails.application.routes.draw do
  root "accounts#index"

  resources :accounts do
    resource :csv_export, only: :show, module: :accounts
    resources :users
    resources :subscriptions
    resources :license_assignments, only: [ :index, :create, :destroy ] do
      collection do
        delete :bulk_destroy
      end
    end
  end

  resources :products
  get "up" => "rails/health#show", as: :rails_health_check
end
