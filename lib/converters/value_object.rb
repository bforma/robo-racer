module Converters
  module ValueObject
    def to_models(value_objects)
      value_objects.map { |value_object| to_model(value_object) }
    end

    def to_model(value_object)
      send("to_#{value_object.class.name.underscore}", value_object)
    end

  private

    def to_board_tile(tile)
      Projections::Mongo::Tile.new(x: tile.x, y: tile.y)
    end

    def to_instruction_card(instruction_card)
      Projections::Mongo::InstructionCard.new(
        action: instruction_card.action,
        amount: instruction_card.amount,
        priority: instruction_card.priority
      )
    end
  end
end
