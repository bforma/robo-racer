Rails.application.routes.draw do
  devise_for :players, controllers: {registrations: "players/registrations"}

  root to: "home#index"

  devise_scope :player do
    resources :games, only: %i(create show)
  end
end
