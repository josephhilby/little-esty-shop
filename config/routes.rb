Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resources :merchants, only: [:index] do
    resources :items, except: [:destroy]
    resources :invoices, only: [:index, :show]
    resources :dashboard, only: [:index]
    resources :discounts, only: [:index, :show, :new, :create]
  end

  get "/admin", to: "admin#index"

  resources :invoice_items

  namespace(:admin) do
    resources :merchants, except: [:destroy]
    resources :invoices, only: [:show, :index, :update]
  end
end