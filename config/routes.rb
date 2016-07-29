Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  resources :games, only: ['index', 'show', 'destroy'] do

    member do
      post :lock
      delete :lock, action: :unlock
    end

    resource :outcome, only: ['create'] do
      # resources :team_outcomes -- not a separate route; subsumed inside Outcome
    end
  end

  resources :players do
    resource :piece, only: ['create', 'update']

    member do
      get :auth
      get :profile
      get :activities
    end

    collection do
      get :'auth-callback'
    end
  end


  match "*path", :to => "application#route_not_found", :via => :all

end
