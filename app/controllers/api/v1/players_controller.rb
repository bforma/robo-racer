module Api
  module V1
    class PlayersController < Api::BaseController
      def show
        player = Player.find(params[:id])
        respond_with player.attributes.slice("id", "name")
      end

      def me
        respond_with current_player
      end
    end
  end
end
