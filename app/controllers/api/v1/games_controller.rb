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
      end

      def join
        dispatch_command! JoinGameCommand.new(
          id: params[:id],
          player_id: current_player.id
        )

        head :accepted
      end

      def leave
        dispatch_command! LeaveGameCommand.new(
          id: params[:id],
          player_id: current_player.id
        )

        head :accepted
      end

      def start
        dispatch_command! StartGameCommand.new(
          id: params[:id],
          player_id: current_player.id
        )

        head :accepted
      end

      def program_robot
        instruction_cards = params.require(:instruction_cards).map do |param|
          InstructionCard.new(
            param[:action],
            param[:amount].to_i, # TODO fix this silly to_i
            param[:priority].to_i
          )
        end

        command = ProgramRobotCommand.new(
          id: params[:id],
          player_id: current_player.id,
          instruction_cards: instruction_cards
        )
        dispatch_command! command

        head :accepted
      end
    end
  end
end
