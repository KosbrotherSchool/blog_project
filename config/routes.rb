Rails.application.routes.draw do
  
  get 'pages/index'
  root 'pages#index'
  post 'pages/send_message'

end
