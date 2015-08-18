require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  get 'pages/index'
  root 'pages#index'
  post 'pages/send_message'

end
