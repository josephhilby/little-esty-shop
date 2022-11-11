require "rails_helper"

RSpec.describe "Merchant Bulk Discount Show page" do 
  before(:each) do 
    @merchant = Merchant.create!(name: "Savory Spice")
    @discount = @merchant.bulk_discounts.create!(discount: 15, threshold: 5)
  end
  describe "As a merchant, when I visit /merchants/:id/bulk_discounts/:id" do 
    it "displays the bulk discount's quantity threshold and percentage discount" do 
      visit merchant_bulk_discount_path(@merchant, @discount)

      expect(page).to have_content("Quantity Threshold: 5 items")
      expect(page).to have_content("Percentage Discount: 15%")
    end
  end
end