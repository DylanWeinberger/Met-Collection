Rails.application.routes.draw do
  root "artworks#index"
  resources :artworks, only: [:index, :show] do
    collection do
      get :more
    end
  end
end