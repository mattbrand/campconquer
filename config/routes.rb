Rails.application.routes.draw do

  ActiveAdmin.routes(self)

  namespace :api do
    resources :gears, only: ['index']
    resources :ammos, only: ['index']
    resources :seasons, only: ['show']

    resources :games, only: ['index', 'show', 'destroy', 'update'] do

      member do
        post :lock
        delete :lock, action: :unlock
      end
    end

    resources :players do
      resource :piece, only: ['create', 'update']

      member do

        post :buy
        post :equip
        post :unequip
        post :claim_steps
        post :claim_active_minutes

      end
    end

    resources :sessions, only: ['new', 'create', 'destroy']

    match "*path", :to => "api#route_not_found", :via => :all

  end # api

  resources :sessions, only: ['create']

  resources :players do

    collection do
      get :'auth-callback'
    end

    member do
      get :auth

      # todo: remove these
      get :profile
      get :activities
      get :steps
    end

  end


  get "/login", to: "sessions#new", as: 'login'
  delete "/logout", to: "sessions#destroy", as: 'logout'

  root to: "statics#index"
  get "/game", to: "statics#game", as: "game"

  # todo: web 404 page
  # match "*path", :to => "application#route_not_found", :via => :all
  get "*any", via: :all, to: "errors#not_found"

end
