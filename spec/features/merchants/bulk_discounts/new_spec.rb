require "rails_helper"

RSpec.describe "New Merchant Bulk Discount page" do 
  before(:each) do 
    @merchant = Merchant.create!(name: "Savory Spice")
    @discount_1 = @merchant.bulk_discounts.create!(discount: 10, threshold: 5)
    @discount_2 = @merchant.bulk_discounts.create!(discount: 20, threshold: 10)
  end

  describe "As a merchant when I visit the merchants/:id/bulk_discounts there's a link to create a new discount" do
    describe "When I click on the link it takes me a to a form to create a new discount" do
      it "the form has fields for percent discount and quantity threshold, when I click submit I'm redirected back to the index where I see the new discount" do
        visit merchant_bulk_discounts_path(@merchant)

        expect(page).to_not have_content("Quantity Threshold: 15 items")
        expect(page).to_not have_content("Percentage Discount: 30%")

        click_on("Create New Bulk Discount")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        expect(page).to have_field(:discount)
        expect(page).to have_field(:threshold)

        fill_in(:discount, with: "30")
        fill_in(:threshold, with: "15")
        click_on("Submit")

        expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
        expect(page).to have_content("Quantity Threshold: 15 items")
        expect(page).to have_content("Percentage Discount: 30%")
      end

      it "doesn't allow me to leave fields empty, and will display a flash message of errors if I do" do 
        visit new_merchant_bulk_discount_path(@merchant)

        click_on("Submit")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        within "#flash-messages" do
          expect(page).to have_content("Error: Threshold can't be blank, Discount can't be blank")
        end
      end

      it "doesn't allow me to infill the percent/threshold with non-integer values and will display flash message of errors" do 
        visit new_merchant_bulk_discount_path(@merchant)

        fill_in(:discount, with: "thirty")
        fill_in(:threshold, with: "fifteen")
        click_on("Submit")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        within "#flash-messages" do
          expect(page).to have_content("Error: Discount is not a number, Threshold is not a number")
        end

        fill_in(:discount, with: "30.5")
        fill_in(:threshold, with: "15.90")
        click_on("Submit")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        within "#flash-messages" do
          expect(page).to have_content("Error: Discount must be an integer, Threshold must be an integer")
        end
      end

      it "doesn't allow me to infill the percent discount field with integers over >=100 or <=0 and will display flash message of errors" do 
        visit new_merchant_bulk_discount_path(@merchant)

        fill_in(:discount, with: "105")
        fill_in(:threshold, with: "15")
        click_on("Submit")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        within "#flash-messages" do
          expect(page).to have_content("Error: Discount must be less than 100")
        end

        fill_in(:discount, with: "-5")
        fill_in(:threshold, with: "15")
        click_on("Submit")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        within "#flash-messages" do
          expect(page).to have_content("Error: Discount must be greater than 0")
        end
      end

      it "doesn't allow me to infill the threshold field with integers less than 0" do 
        visit new_merchant_bulk_discount_path(@merchant)

        fill_in(:discount, with: "30")
        fill_in(:threshold, with: "-15")
        click_on("Submit")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        within "#flash-messages" do
          expect(page).to have_content("Error: Threshold must be greater than 0")
        end
      end

      it "doesn't let me create a discount that will never be applied" do 
        # discount_3 = @merchant.bulk_discounts.create!(discount: 15, threshold: 15)
        visit new_merchant_bulk_discount_path(@merchant)

        fill_in(:discount, with: 15)
        fill_in(:threshold, with: 15)
        click_on("Submit")

        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
        within "#flash-messages" do
          expect(page).to have_content("Error: Discount is less than the current highest discount, but with a greater threshold, and will never be applied")
        end
      end
    end
  end

       
end