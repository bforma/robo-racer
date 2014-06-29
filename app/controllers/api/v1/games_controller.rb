module Api
  module V1
    class GamesController < Api::BaseController
      def show
        respond_with Game.find(params[:id])
      end
    end
  end
end
