Rails.application.routes.draw do
  resources :project_members, except: [:new, :edit]
  resources :tasks, except: [:new, :edit]
  resources :localized_values, only: [ :update ]
  resources :general_contacts, only: [:create], :path => "contato"

  mount_devise_token_auth_for 'User', at: 'api/v1/auth', controllers: {
    registrations:  'overrides/registrations',
    omniauth_callbacks:  'overrides/omniauth_callbacks'
  }
  
  scope :api do
    scope :v1 do
      get 'me', to: 'users#me'

      resources :tasks, only: [:index]

      resources :users do 
        get 'update_image', on: :collection
      end
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq-dashboard'
  
  # resources :services, only: [ :create, :update, :destroy ]
  # resources :work_contacts, only: [:create], :path => "trabalhe_conosco"
  # resources :general_contacts, only: [:create], :path => "contato"

  scope "(:locale)", locale: /pt-BR|en|es/ do
    root to: 'pages#home'
  end
end
