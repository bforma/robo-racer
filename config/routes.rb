Rails.application.routes.draw do
  devise_for :players, controllers: {registrations: "players/registrations"}

  root to: "home#index"
end
