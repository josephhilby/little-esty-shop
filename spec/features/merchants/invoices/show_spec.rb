require 'rails_helper'
require 'date'

RSpec.describe 'On the Merchant Invoices Show Page' do
  before(:each) do
    @merchant_1 = Merchant.create!(name: "Dave")
    @merchant_2 = Merchant.create!(name: "Kevin")

    @merchant_1_item_1 = @merchant_1.items.create!(name: "Pencil", description: "Writing implement", unit_price: 1)
    @merchant_1_item_2 = @merchant_1.items.create!(name: "Mechanical Pencil", description: "Writing implement", unit_price: 3)
    @merchant_2_item_1 = @merchant_2.items.create!(name: "A Thing", description: "Will do the thing", unit_price: 2)

    @customer_1 = Customer.create!(first_name: "Bob", last_name: "Jones")
    @customer_2 = Customer.create!(first_name: "Milly", last_name: "Smith")

    @customer_1_invoice_1 = @customer_1.invoices.create!(status: 1)
    @customer_2_invoice_1 = @customer_2.invoices.create!(status: 2)

    @invoice_item_1 = InvoiceItem.create!(invoice: @customer_1_invoice_1, item: @merchant_1_item_1, quantity: 1, status: 0, unit_price: 1)
    @invoice_item_2 = InvoiceItem.create!(invoice: @customer_1_invoice_1, item: @merchant_1_item_2, quantity: 5, status: 1, unit_price: 3)
    @invoice_item_3 = InvoiceItem.create!(invoice: @customer_1_invoice_1, item: @merchant_2_item_1, quantity: 8, status: 2)
    @invoice_item_4 = InvoiceItem.create!(invoice: @customer_2_invoice_1, item: @merchant_1_item_1, quantity: 9, status: 2)

    @merchant = Merchant.create!(name: "Savory Spice")
    @discount = @merchant.bulk_discounts.create!(discount: 10, threshold: 5)
    @cumin = @merchant.items.create!(name: "Cumin", description: "2 oz of ground cumin in a glass jar.", unit_price: 10)
    @thyme = @merchant.items.create!(name: "Thyme", description: "2 oz of dried thyme in a glass jar.", unit_price: 10)

    @other_merchant = Merchant.create!(name: "Other Merchant")
    @other_item = @other_merchant.items.create!(name: "Other Item", description: "some stuff", unit_price: 15)

    @customer = Customer.create!(first_name: "Amanda", last_name: "Ross")
    @invoice = @customer.invoices.create!(status: "In Progress")
    InvoiceItem.create!(invoice: @invoice, item: @cumin, quantity: 5, unit_price: 10, status: 0)
    InvoiceItem.create!(invoice: @invoice, item: @thyme, quantity: 2, unit_price: 10, status: 0)
    InvoiceItem.create!(invoice: @invoice, item: @other_item, quantity: 10, unit_price: 10, status: 0)
    @invoice.transactions.create!(credit_card_number: 1234565312341234, credit_card_expiration_date: "10/26", result: "success")
  end

  describe 'When I visit /merchants/:merchant_id/invoices/:invoice_id' do
    describe 'Then I see' do
      it 'invormation related to that invoice' do
        visit "/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}"

        expect(page).to have_content("Invoice # #{@customer_1_invoice_1.id}")

        within "#invoice-stats-#{@customer_1_invoice_1.id}" do
          expect(page).to have_content(@customer_1_invoice_1.status)
          expect(page).to have_content(@customer_1_invoice_1.created_at.strftime("%A, %d %B %Y"))
        end

        within "#customer-info-#{@customer_1_invoice_1.id}" do
          expect(page).to have_content(@customer_1.first_name)
          expect(page).to have_content(@customer_1.last_name)
        end
      end

      it 'only invormation related to that invoice' do
        visit "/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}"

        expect(page).to_not have_content("Created at: #{@customer_2_invoice_1.id}")
      end

      it 'all the items on this invoice and their name, quanitity, price, and invoice status' do
        visit "/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}"

        within "#item-info-#{@customer_1_invoice_1.id}" do
          expect(page).to have_content(@merchant_1_item_1.name)
          expect(page).to have_content(@invoice_item_1.quantity)
          expect(page).to have_content(@merchant_1_item_1.unit_price)

          expect(page).to have_content(@merchant_1_item_2.name)
          expect(page).to have_content(@invoice_item_2.quantity)
          expect(page).to have_content(@merchant_1_item_2.unit_price)
        end
      end

      it 'only items for this invoice and merchant' do
        visit "/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}"

        within "#item-info-#{@customer_1_invoice_1.id}" do
          expect(page).to_not have_content(@merchant_2_item_1.name)
          expect(page).to_not have_content(@invoice_item_3.quantity)
          expect(page).to_not have_content(@merchant_2_item_1.unit_price)
        end
      end

      it 'total revenue for all items on invoice' do
        visit "/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}"

        within "#invoice-stats-#{@customer_1_invoice_1.id}" do

          expect(page).to have_content((@merchant_1_item_1.unit_price * @invoice_item_1.quantity) + (@merchant_1_item_2.unit_price * @invoice_item_2.quantity))
        end
      end

      describe 'a form to change the items status' do
        it 'that has a select field that displays the items current status' do
          visit "/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}"

          within "#form-#{@merchant_1_item_1.id}" do
            expect(page).to have_select(selected: "packaged")
          end
          within "#form-#{@merchant_1_item_2.id}" do
            expect(page).to have_select(selected: "pending")
          end
        end

        it 'that allows me to select a new status and update the item by pressing "Update Item Status"' do
          visit "/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}"

          within "#form-#{@merchant_1_item_1.id}" do
            select 'pending', from: 'invoice_item_status'
            click_button "Update Item Status"

            expect(current_path).to eq("/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}")
            expect(page).to have_select(selected: "pending")
          end
        end
      end

      describe "Total Revenue and Discounted Revenue" do 
        it "shows the total revenue for the merchant from this invoice (not including discounts)" do 
          visit merchant_invoice_path(@merchant, @invoice)

          expect(page).to have_content("Total Revenue: $70.00")
        end

        it "shows the total discounted revenue for the merchant from this invoice which includes bulk discounts in the calculation" do 
          visit merchant_invoice_path(@merchant, @invoice)

          expect(page).to have_content("Total Discounted Revenue: $65.00")
        end

        it "shows a link for each bulk discount's show page next to each item that has a bulk discount applied" do 
          visit merchant_invoice_path(@merchant, @invoice)

          within "#item-#{@cumin.id}" do 
            expect(page).to have_link("#{@discount.id}", href: merchant_bulk_discount_path(@merchant, @discount))
          end

          within "#item-#{@thyme.id}" do 
            expect(page).to_not have_content("#{@discount.id}")
          end
        end
      end
    end
  end
end