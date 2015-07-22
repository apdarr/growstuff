require 'rails_helper'

feature "Harvesting a crop", :js do
  let(:member) { create :member }
  let!(:maize) { create :maize }

  background do
    login_as member
    visit new_harvest_path
    sync_elasticsearch [maize]
  end

  it_behaves_like "crop suggest", "harvest", "crop"

  scenario "Creating a new harvest" do
    fill_autocomplete "crop", with: "mai"
    select_from_autocomplete "maize"
    within "form#new_harvest" do
      fill_in "When?", with: "2014-06-15"
      fill_in "How many?", with: 42
      fill_in "Weighing (in total):", with: 42
      fill_in "Notes", with: "It's killer."
      click_button "Save"
    end

    expect(page).to have_content "Harvest was successfully created"
  end

  scenario "Clicking link to owner's profile" do
    visit harvests_by_owner_path(member)
    click_link "View #{member}'s profile >>"
    expect(current_path).to eq member_path member
  end

  scenario "Harvesting from crop page" do
    visit crop_path(maize)
    click_link "Harvest this"
    within "form#new_harvest" do
      expect(page).to have_selector "input[value='maize']"
      click_button "Save"
    end

    expect(page).to have_content "Harvest was successfully created"
    expect(page).to have_content "maize"
  end

  context "Editing a harvest" do
    let(:existing_harvest) { create :harvest, crop: maize, owner: member }

    background do
      visit harvest_path(existing_harvest)
      click_link "Edit"
    end

    scenario "Saving wihout edits" do
      # Check that the autosuggest helper properly fills inputs with
      # existing resource's data
      click_button "Save"
      expect(page).to have_content "Harvest was successfully updated"
      expect(page).to have_content "maize"
    end
  end
end

