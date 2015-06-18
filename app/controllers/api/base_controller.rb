module Api
  class BaseController < ApplicationController
    NOT_FOUND_ERRORS = [
      ActiveRecord::RecordNotFound,
      Fountain::EventStore::StreamNotFoundError,
      Fountain::Repository::AggregateNotFoundError,
    ]

    respond_to :json
    before_action :restrict_access
    rescue_from *NOT_FOUND_ERRORS, with: :not_found
    rescue_from DomainError, with: :domain_error
    rescue_from InvalidCommandError, with: :invalid_command_error

    skip_before_filter :verify_authenticity_token

    private

    def restrict_access
      head :unauthorized unless current_player
    end

    def current_player
      access_token = params[:access_token]
      Player.where(access_token: access_token).first if access_token.present?
    end
    memoize :current_player

    def not_found
      head :not_found
    end

    def domain_error(error)
      errors = [
        {
          code: error.class.name.underscore,
          title: error.class.name.underscore.humanize
        }
      ]
      render json: { errors: errors }, status: 422
    end

    def invalid_command_error(error)
      errors = error.command.errors.map do |attribute, msg|
        {
          code: attribute,
          title: msg
        }
      end
      render json: { errors: errors }, status: 422
    end
  end
end
