Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  resources :gears, only: ['index']

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

      post :buy   # should this be a nested items resource instead?
      post :equip # should this be a nested items resource instead?
      post :claim_steps  # should this be a nested currency resource instead?
      post :claim_moderate  # should this be a nested currency resource instead?
      post :claim_vigorous  # should this be a nested currency resource instead?

      # todo: remove these
      get :profile
      get :activities
      get :steps
    end

    collection do
      get :'auth-callback'
    end
  end


  match "*path", :to => "application#route_not_found", :via => :all

end
