Rails.application.routes.draw do
  resource :session
  get "signin", to: "sessions#new", as: :signin
  get "signout", to: "sessions#signout", as: :signout
  get "signup", to: "registrations#new", as: :signup
  get "auth/failure", to: "omniauth_sessions#failure"
  get "auth/:provider/callback", to: "omniauth_sessions#create"

  # One click into the admin screens while working locally.
  post "dev/signin", to: "dev/sessions#create", as: :dev_signin if Rails.env.development?
  post "signup", to: "registrations#create"
  get "login", to: redirect("/signin")
  get "logout", to: redirect("/signout")
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    resources :invitations, only: %i[ new create destroy ] do
      post :resend, on: :member
    end
    resources :users, only: %i[ index update ]
    resources :guides, only: %i[ index new create edit update ] do
      get :history, on: :member
    end

    resources :cheat_sheets, only: %i[ index new create edit update ] do
      get :history, on: :member
    end
    resource :account, only: %i[ show update ]
    resources :passkeys, only: %i[ create destroy ]
    resource :passkey_challenge, only: :create

    root "accounts#show"
  end

  resources :guides, only: %i[ index show ]
  resources :cheat_sheets, only: %i[ index show ]
  resources :waypoints, only: %i[ index show ]
  get "search", to: "search#index"
  get "tags/:name", to: "tags#show", as: :tag, constraints: { name: %r{[^/]+} }
  get "worldwide", to: "worldwide#show"

  root "home#show"

  get "manifest" => "pwa#manifest", as: :pwa_manifest
  get "service-worker" => "pwa#service_worker", as: :pwa_service_worker
  get "offline", to: "offline#show"

  # Defines the root path route ("/")
  # root "posts#index"
end
