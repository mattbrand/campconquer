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
        get :auth

        post :buy
        post :equip
        post :claim_steps
        post :claim_active_minutes

        # todo: remove these
        get :profile
        get :activities
        get :steps
      end

      collection do
        get :'auth-callback'
      end
    end

    resources :sessions, only: ['create']


    match "*path", :to => "api#route_not_found", :via => :all

  end


  # todo: web 404 page
  # match "*path", :to => "application#route_not_found", :via => :all
  get "*any", via: :all, to: "errors#not_found"

end
