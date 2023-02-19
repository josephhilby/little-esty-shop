require "rails_helper"

RSpec.describe "the merchant items edit page" do
  before(:each) do
  @merchant = create(:merchant)
  @item = create(:item, merchant: @merchant)

  visit merchant_item_path(@merchant, @item)
  end
  describe "As a merchant when I visit the merchant item show page and click on the update item link" do
    it "takes me to a merchan item edit page with field already filled out, when I submit the form i'm redirected to the show page where i see my edits" do
      click_on("Update Item")

      expect(current_path).to eq(edit_merchant_item_path(@merchant, @item))
      expect(page).to have_field("name", with: @item.name)
      expect(page).to have_field("description", with: @item.description)
      expect(page).to have_field("unit_price", with: @item.unit_price)
      expect(page).to have_button("Submit")

      fill_in("name", with: "Dead Spells item")
      fill_in("description", with: "This is a hundred year old tome full of necromancy spells. Very rare.")
      click_button("Submit")

      expect(current_path).to eq(merchant_item_path(@merchant, @item))
      expect(page).to have_content("Dead Spells item")
      expect(page).to have_content("Description: This is a hundred year old tome full of necromancy spells. Very rare.")
      expect(page).to have_content("Current Price: $#{@item.unit_price}.00")
      within "#flash-messages" do
        expect(page).to have_content("This item's information has been successfully updated!")
      end
    end
  end
end