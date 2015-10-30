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
    get 'movie/reviews'
    post 'movie/update_reviews'
    get 'movie/blogs'
    get 'movie/movie_by_time'
    get 'movie/blog_posts'
    get 'movie/review_rank'
    get 'movie/point_rank'
    get 'movie/messages'
    post 'movie/update_messages'

    get 'movie/open_link_list'
    patch 'movie/update_open_link'

    get 'movie/imdb_list'
    patch 'movie/update_imdb_and_potato_and_class'

    post 'movie/update_reply'
  end

  namespace :api2 do
    get 'movie/movies'
    get 'movie/rank_movies'
  end

  get 'message/messages'
  post 'message/update_messages'
  post 'message/update_reply'

  get 'pages/index'
  root 'pages#index'
  post 'pages/send_message'

end
