require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  namespace :api do
    get 'movie/rank_movies'
    get 'movie/movies'
    get 'movie/areas'
    get 'movie/theaters'
    get 'movie/movietimes'
    get 'movie/news'
  end

  get 'pages/index'
  root 'pages#index'
  post 'pages/send_message'

end
