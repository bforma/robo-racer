class Players::RegistrationsController < Devise::RegistrationsController
  def new
    self.resource = CreatePlayer.new
  end

  def create
    self.resource = command = CreatePlayer.new(
      sign_up_params.merge(id: new_uuid)
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
