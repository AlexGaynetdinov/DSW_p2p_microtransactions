Rails.application.routes.draw do
  devise_for :users,
              path: '',
              path_names: {
                sign_in: 'login',
                sign_out: 'logout',
                registration: 'signup'
              },
              controllers: {
                sessions: 'users/sessions',
                registrations: 'users/registrations'
              }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # User management routes
  get    '/profile',      to: 'users#me'
  get    '/users',        to: 'users#index'
  get    '/users/:id',    to: 'users#show'
  put    '/users/:id',    to: 'users#update'
  delete '/users/:id',    to: 'users#destroy'

  # Credit card top-up
  post   '/top_up_balance', to: 'balance#top_up'

  # Transactions
  resources :transactions, only: [:create, :index]

  resources :money_requests, only: [:create, :index] do
    member do
      post 'accept'
      post 'reject'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
