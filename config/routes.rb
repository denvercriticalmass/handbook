Rails.application.routes.draw do
  resource :session
  get "signin", to: "sessions#new", as: :signin
  get "signout", to: "sessions#signout", as: :signout
  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  get "login", to: redirect("/signin")
  get "logout", to: redirect("/signout")
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    resources :invitations, only: %i[ new create ]
    resources :users, only: %i[ index update ]
    resources :guides, only: %i[ index new create edit update ]
    resources :cheat_sheets, only: %i[ index new create edit update ]
    resource :account, only: %i[ show update ]

    root "accounts#show"
  end

  resources :guides, only: %i[ index show ]
  resources :cheat_sheets, only: %i[ index show ]
  get "worldwide", to: "worldwide#show"

  root "home#show"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
