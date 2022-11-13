require "rails_helper"
require "date"

RSpec.describe "Admin Invoice show page" do 
  before(:each) do 
    merchant = Merchant.create!(name: "Practical Magic Shop")
    @discount_1 = merchant.bulk_discounts.create!(discount: 10, threshold: 3)
    @book = merchant.items.create!(name: "Book of the dead", description: "book of necromancy spells", unit_price: 4)
    @candle = merchant.items.create!(name: "Candle of life", description: "candle that gifts everlasting life", unit_price: 15)
    @potion = merchant.items.create!(name: "Love potion", description: "One serving size of true love potion", unit_price: 10)

    other_merchant = Merchant.create!(name: "Savory Spice")
    @discount_2 = other_merchant.bulk_discounts.create!(discount: 10, threshold: 5)
    @cumin = other_merchant.items.create!(name: "Cumin", description: "2 oz of ground cumin in a glass jar.", unit_price: 10)
  
    @customer = Customer.create!(first_name: "Gandalf", last_name: "Thegrey")
    feb_third = DateTime.new(2022,2,3,4,5,6)
    march_third = DateTime.new(2022,3,3,6,2,3)

    @invoice_1 = @customer.invoices.create!(status: 2, created_at: feb_third)
    @invoice_2 = @customer.invoices.create!(status: 1, created_at: march_third)

    InvoiceItem.create!(invoice: @invoice_1, item: @book, quantity: 1, unit_price: 4, status: 1)
    InvoiceItem.create!(invoice: @invoice_1, item: @candle, quantity: 2, unit_price: 15, status: 2)

    InvoiceItem.create!(invoice: @invoice_2, item: @book, quantity: 1, unit_price: 4, status: 1)
    InvoiceItem.create!(invoice: @invoice_2, item: @candle, quantity: 2, unit_price: 10, status: 2)
    InvoiceItem.create!(invoice: @invoice_2, item: @potion, quantity: 3, unit_price: 10, status: 2)
    InvoiceItem.create!(invoice: @invoice_2, item: @cumin, quantity: 5, unit_price: 10, status: 1)
  end

  describe "As an admin, when I visit admin/invoices/:id" do 
    it "shows information related to that invoice including, id, status, created_at date, and Customer first and last name" do       
      visit admin_invoice_path(@invoice_1)

      expect(page).to have_content("Invoice ##{@invoice_1.id}")
      expect(page).to have_content("Status:")
      expect(page).to have_content("Created on: Thursday, February 03, 2022")
      expect(page).to have_content("Customer:")
      expect(page).to have_content("Gandalf Thegrey")
    end

    it "lists all the items on the invoice including: item name, quantity, price, and the Invoice Item status" do 
      visit admin_invoice_path(@invoice_1)

      within "#items-details" do 
        expect(page).to have_content("Items on this Invoice:")
        expect(page).to have_content("Item Name")
        expect(page).to have_content("Quantity")
        expect(page).to have_content("Unit Price")
        expect(page).to have_content("Status")

        expect(page).to have_content("Book of the dead")
        expect(page).to have_content("2")
        expect(page).to have_content("4")
        expect(page).to have_content("pending")

        expect(page).to have_content("Candle of life")
        expect(page).to have_content("2")
        expect(page).to have_content("15")
        expect(page).to have_content("shipped")
      end
    end

    it "displays the invoice status as a select field, with the current status selected" do 
      visit admin_invoice_path(@invoice_1)

      expect(page).to have_select("invoice_status")
      expect(page).to have_select(selected: "In Progress")
      expect(page).to have_button("Update Invoice Status")
    end

    it "when I click Update Invoice Status, the admin invoice show page reloads and see the status has been updated" do 
      visit admin_invoice_path(@invoice_1)

      select 'Completed', from: 'invoice_status'
      click_button("Update Invoice Status")

      expect(current_path).to eq(admin_invoice_path(@invoice_1))
      expect(page).to have_select(selected: "Completed")
    end
  end
  
  describe 'total revenue and discounted revenue' do 
    it 'displays the total revenue that will be generated from this invoice' do 
      visit admin_invoice_path(@invoice_2)

      expect(page).to have_content("Total Revenue: $104")
    end

    it "displays discounted revenue for this invoice which is includes all applicable bulk discounts" do 
      visit admin_invoice_path(@invoice_2)

      expect(page).to have_content("Total Discounted Revenue: $96")
    end
  end
end