require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  namespace :api do
    get 'movie/version'
    get 'movie/rank_movies'
    get 'movie/movies'
    get 'movie/areas'
    get 'movie/theaters'
    get 'movie/movietimes'
    get 'movie/news'
    get 'movie/youtubes'
    get 'movie/photos'
    get 'movie/trailers'
    get 'movie/search'
    get 'movie/open_link_list'
    patch 'movie/update_open_link'
  end

  get 'pages/index'
  root 'pages#index'
  post 'pages/send_message'

end
