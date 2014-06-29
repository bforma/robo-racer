Rails.application.routes.draw do
  devise_for :players, controllers: {registrations: "players/registrations"}

  root to: "home#index"

  devise_scope :player do
    resources :games, only: %i(create show)

    namespace :api, defaults: {format: 'json'} do
      scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
        resources :players, only: %i(show) do
          get 'me', on: :collection
        end
      end
    end
  end
end
