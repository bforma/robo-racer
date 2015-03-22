require 'rails_helper'

describe Players::RegistrationsController do
  it "registers a new player account" do
    visit root_path

    click_on "Register"
    fill_in "player[name]", with: "Bob"
    fill_in "player[email]", with: "bob@localhost.local"
    fill_in "player[password]", with: "secret"
    fill_in "player[password_confirmation]", with: "secret"
    click_on "Sign up"

    expect(page).to have_content "Your account has been created successfully."
  end
end
