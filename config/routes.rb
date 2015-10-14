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
    get 'movie/reviews'
    post 'movie/update_reviews'
    get 'movie/blogs'
    get 'movie/movie_by_time'
    get 'movie/blog_posts'
    get 'movie/review_rank'
    get 'movie/point_rank'
    get 'movie/messages'
    post 'movie/update_messages'
  end

  get 'pages/index'
  root 'pages#index'
  post 'pages/send_message'

end
