require "rails_helper"

describe Devise::SessionsController do
  before do
    given_events(PlayerAggregate: [build(
      :player_was_created,
      email: "bob@localhost.local",
      name: "Bob",
      password: "secret"
    )])
  end

  it "logs in a user" do
    visit root_path

    click_on "Log in"
    within ".mod-sessions_new" do
      fill_in "player[email]", with: "bob@localhost.local"
      fill_in "player[password]", with: "secret"
      click_on "Log in"
    end

    expect(page).to have_no_link("Log in")
    expect(page).to have_link("Log out")
    expect(page).to have_content("Bob")
  end

  context "given a logged in user" do
    before { login_as(Player.last, scope: :player) }

    it "logs out a user" do
      visit root_path

      click_on "Log out"

      expect(page).to have_no_link("Log out")
      expect(page).to have_link("Log in")
    end
  end
end
