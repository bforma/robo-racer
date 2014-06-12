class Players::RegistrationsController < Devise::RegistrationsController
  def new
    self.resource = RoboRacer::CreatePlayer.new
  end

  def create
    self.resource = command = RoboRacer::CreatePlayer.new(
      sign_up_params.merge(id: SecureRandom.uuid)
    )
    if command.valid?
      execute(command)
      redirect_to root_path, notice: "Your account has been created successfully."
    else
      render "new"
    end
  end

private

  def sign_up_params
    params.require(:player).permit(
      :name, :email, :password, :password_confirmation
    )
  end
end
