module EventsHelper
  def new_uuid
    SecureRandom.uuid
  end
end
