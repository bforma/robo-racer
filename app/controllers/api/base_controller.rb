module Api
  class BaseController < ApplicationController
    extend Memoist

    respond_to :json
    before_action :restrict_access
    rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

  private

    def restrict_access
      head :unauthorized unless current_player
    end

    def current_player
      Player.where(
        :access_token => params[:access_token],
        :access_token.nin => [nil, ""],
        :access_token.exists => true
      ).first
    end
    memoize :current_player

    def not_found
      head :not_found
    end
  end
end
