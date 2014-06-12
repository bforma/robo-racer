require 'bcrypt'

module PasswordHelper
  def self.encrypt(password)
    return "" if password.blank?
    BCrypt::Password.create(password)
  end
end
