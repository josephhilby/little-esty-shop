require "rails_helper"

RSpec.describe "Merchant bulk discount edit page" do 
  before(:each) do 
    @merchant = Merchant.create!(name: "Savory Spice")
    @discount = @merchant.bulk_discounts.create!(discount: 15, threshold: 5)
  end

  describe "As a merchant, when I visit a bulk discount show page" do 
    it "has a button to Edit Bulk Discount, when clicked it takes me to an edit page" do 
      visit merchant_bulk_discount_path(@merchant, @discount) 

      expect(page).to have_content("Percentage Discount: 15%")
      expect(page).to have_content("Quantity Threshold: 5 items")

      click_button("Edit Bulk Discount")

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant, @discount))
      expect(page).to have_field(:discount, with: "15")
      expect(page).to have_field(:threshold, with: "5")
    end
  end

  describe "On the edit bulk discount page" do 
    it "when I change the information and click submit I am redirected to the show page, where the attributes have been updated" do 
      visit edit_merchant_bulk_discount_path(@merchant, @discount)
      fill_in(:discount, with: "20")
      fill_in(:threshold, with: "10")

      click_button("Submit")

      expect(current_path).to eq(merchant_bulk_discount_path(@merchant, @discount))
      expect(page).to have_content("Percentage Discount: 20%")
      expect(page).to have_content("Quantity Threshold: 10 items")    
    end

    it "when I change the information to invalid data, it reloads the edit page with error flash messages" do 
      visit edit_merchant_bulk_discount_path(@merchant, @discount)
      fill_in(:discount, with: "twenty")
      fill_in(:threshold, with: "ten")
      click_button("Submit")

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant, @discount))
      within "#flash-messages" do
        expect(page).to have_content("Error: Discount is not a number, Threshold is not a number")
      end

      fill_in(:discount, with: "105")
      fill_in(:threshold, with: "-50")
      click_button("Submit")

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant, @discount))
      within "#flash-messages" do
        expect(page).to have_content("Error: Discount must be less than 100, Threshold must be greater than 0")
      end
    end
  end
end