Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resources :companies, only: [ :index, :show, :new, :create, :update, :destroy ] do
    resources :financial_closings, only: [ :index, :edit, :create, :update ]
    resources :financial_statements, only: [ :show ]
    resource :general_ledger, only: [ :show ]
    resources :journal_entries, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resources :members, only: [ :index, :create, :destroy ] do
      resources :invitation_mails, only: [ :create ]
    end
  end
  resources :invitations, only: [ :show, :update ]
  resource :public_key_credential_request_options, only: [ :show ]
  resource :session, only: [ :new, :create, :update, :destroy ]
  get "signup", to: "users#new"
  resources :users, only: [ :show, :create, :destroy ] do
    resource :public_key_credential_creation_options, only: [ :show ]
    resources :passkeys, only: [ :create, :destroy ]
  end

  # Defines the root path route ("/")
  root "companies#index"
end
