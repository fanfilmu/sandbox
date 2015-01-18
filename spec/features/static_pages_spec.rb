require "rails_helper"
require "support/select2"

describe "Static pages", js: true do
  before { visit static_pages_home_path }

  describe "when visiting home page" do
    scenario "selects" do
      expect(page).to have_select2("Super", with_options: ["Funny one"])
      expect(page).not_to have_select2("option2")
      expect(page).to have_select2("Wow")
    end
  end
end
