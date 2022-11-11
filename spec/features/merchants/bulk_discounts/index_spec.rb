require "rails_helper"

RSpec.describe "Merchant Bulk Discounts Index page" do 
  before(:each) do 
    @merchant = Merchant.create!(name: "Savory Spice")
    @discount_1 = @merchant.bulk_discounts.create!(discount: 10, threshold: 5)
    @discount_2 = @merchant.bulk_discounts.create!(discount: 20, threshold: 10)
    @discount_3 = @merchant.bulk_discounts.create!(discount: 30, threshold: 15)
  end

  describe "As a merchant, when I visit my merchant dashboard" do 
    it "has a link to view all of my discounts, which takes you to the discounts index" do 
      visit merchant_dashboard_index_path(@merchant)

      expect(page).to have_link("My Discounts")

      click_link("My Discounts")

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
    end
  end

  describe "As a merchant, when I visit my merchant discounts index page" do 
    it "displays all of my bulk discounts including discount percentage and quantity thresholds" do 
      visit merchant_bulk_discounts_path(@merchant)

      within "#bulk-discount-#{@discount_1.id}" do 
        expect(page).to have_content("Bulk Discount ##{@discount_1.id}")
        expect(page).to have_content("Quantity Threshold: 5 items")
        expect(page).to have_content("Percentage Discount: 10%")
      end

      within "#bulk-discount-#{@discount_2.id}" do 
        expect(page).to have_content("Bulk Discount ##{@discount_2.id}")
        expect(page).to have_content("Quantity Threshold: 10 items")
        expect(page).to have_content("Percentage Discount: 20%")
      end

      within "#bulk-discount-#{@discount_3.id}" do 
        expect(page).to have_content("Bulk Discount ##{@discount_3.id}")
        expect(page).to have_content("Quantity Threshold: 15 items")
        expect(page).to have_content("Percentage Discount: 30%")
      end
    end

    it "each bulk discount listed includes a link to its show page" do 
      visit merchant_bulk_discounts_path(@merchant)

      expect(page).to have_link("Bulk Discount ##{@discount_1.id}", href: merchant_bulk_discount_path(@merchant, @discount_1))
      expect(page).to have_link("Bulk Discount ##{@discount_2.id}", href: merchant_bulk_discount_path(@merchant, @discount_2))
      expect(page).to have_link("Bulk Discount ##{@discount_3.id}", href: merchant_bulk_discount_path(@merchant, @discount_3))
    end
  end
end