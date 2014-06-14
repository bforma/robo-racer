class CreatePlayer < RoboRacer::Command::Base
  attr_accessor :name, :email, :password, :password_confirmation

  validates_presence_of :name, :email, :password, :password_confirmation
  validate :password_equal_to_confirmation

  after_validation :encrypt_passwords, :clear_passwords

  def password_equal_to_confirmation
    unless password == password_confirmation
      errors.add :password, :unequal_to_confirmation
    end
  end

  def encrypt_passwords
    self.password = self.password_confirmation = PasswordHelper.encrypt(password)
  end

  def clear_passwords
    if errors.any?
      self.password = self.password_confirmation = nil
    end
  end
end
