module Api
  module V1
    class GamesController < Api::BaseController
      def show
        respond_with current_game
      end

      def join
        execute JoinGameCommand.new(
          id: current_game.id,
          player_id: current_player.id
        )

        head :accepted
      end

      def leave
        execute LeaveGameCommand.new(
          id: current_game.id,
          player_id: current_player.id
        )

        head :accepted
      end

      def start
        execute StartGameCommand.new(
          id: current_game.id,
          player_id: current_player.id
        )

        head :accepted
      end

    private

      def current_game
        Game.find(params[:id])
      end
      memoize :current_game
    end
  end
end
