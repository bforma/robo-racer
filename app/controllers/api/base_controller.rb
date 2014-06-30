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
      access_token = params[:access_token]
      Player.where(:access_token => access_token).first if access_token.present?
    end
    memoize :current_player

    def not_found
      head :not_found
    end
  end
end
