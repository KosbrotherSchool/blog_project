require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  namespace :api do
    get 'movie/rank_movies'
    get 'movie/first_round_movies'
    get 'movie/second_round_movies'
    get 'movie/areas'
    get 'movie/theaters'
    get 'movie/movie_movietime'
    get 'movie/theater_movietime'
    get 'movie/news'
  end

  get 'pages/index'
  root 'pages#index'
  post 'pages/send_message'

end
