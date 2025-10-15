Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "signup", to: "users#new"
  resources :users, only: [ :show, :create, :destroy ] do
    resources :passkeys, only: [ :create ]
  end

  resources :companies, only: [ :index, :show, :new, :create, :update, :destroy ] do
    resource :general_ledger, only: [ :show ]
    resources :journal_entries, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resources :members, only: [ :index, :create, :destroy ]
  end
  resources :invitations, only: [ :show, :update ]

  resource :session, only: [ :new, :create, :update, :destroy ]

  resources :financial_closings, only: [ :index, :create ] do
    scope module: :financial_closings do
      resource :statements, only: [ :show ]
    end
  end
  resource :financial_closing, only: [ :edit, :update ]

  # Defines the root path route ("/")
  root "companies#index"
end
