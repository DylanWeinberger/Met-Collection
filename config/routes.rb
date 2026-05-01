Rails.application.routes.draw do
  root "artworks#index"
  resources :artworks, only: [:index, :show]
end