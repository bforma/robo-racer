module Api
  module V1
    class GamesController < Api::BaseController

      def events
        events = gateway.event_store.load_all(GameAggregate.name, params[:id])
        respond_with(events.map do |event|
          {
            payload_type: event.payload_type.name,
            payload: event.payload
          }
        end)
      rescue Fountain::EventStore::StreamNotFoundError
        head :not_found
      end

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

      def program_robot
        instruction_cards = params[:instruction_cards].map do |_, param|
          InstructionCard.new(
            param[:action],
            param[:amount].to_i, # TODO fix this silly to_i
            param[:priority].to_i
          )
        end

        command = ProgramRobotCommand.new(
          id: current_game.id,
          player_id: current_player.id,
          instruction_cards: instruction_cards
        )
        raise InvalidCommandError if command.invalid?
        execute command

        head :accepted
      end

    private

      def current_game
        Projections::Mongo::Game.find(params[:id])
      end
      memoize :current_game
    end
  end
end
