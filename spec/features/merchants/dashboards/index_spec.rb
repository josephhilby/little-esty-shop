require 'rails_helper'
require 'date'

RSpec.describe 'On the Merchant Dashboard Index Page' do
  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @merchant_1_item_1 = create(:item, merchant: @merchant_1)
    @merchant_1_item_not_ordered = create(:item, merchant: @merchant_1)
    @merchant_1_item_3 = create(:item, merchant: @merchant_1)
    @merchant_2_item_1 = create(:item, merchant: @merchant_2)

    @customer_1 = create(:customer)
    @customer_2 = create(:customer)
    @customer_3 = create(:customer)
    @customer_4 = create(:customer)
    @customer_5 = create(:customer)
    @customer_6 = create(:customer)

    date = DateTime.new(2022,11,1,3,4,5)

    @customer_1_invoice_1 = create(:invoice, customer: @customer_1, status: 1, created_at: date)
    @customer_1_invoice_2 = create(:invoice, customer: @customer_1, status: 1)

    @customer_2_invoice_1 = create(:invoice, customer: @customer_2, status: 1)
    @customer_3_invoice_1 = create(:invoice, customer: @customer_3, status: 1)
    @customer_4_invoice_1 = create(:invoice, customer: @customer_4, status: 1)
    @customer_5_invoice_1 = create(:invoice, customer: @customer_5, status: 1)

    @customer_6_invoice_1 = create(:invoice, customer: @customer_6, status: 1)
    @customer_6_invoice_2 = create(:invoice, customer: @customer_6, status: 0)

    @invoice_item_1 = create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 4, status: 2)
    create(:invoice_item, invoice: @customer_1_invoice_2, item: @merchant_2_item_1, quantity: 1, unit_price: 4, status: 0)

    create(:invoice_item, invoice: @customer_2_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 4, status: 2)
    create(:invoice_item, invoice: @customer_3_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 4, status: 2)
    create(:invoice_item, invoice: @customer_4_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 4, status: 2)
    create(:invoice_item, invoice: @customer_5_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 4, status: 2)

    @invoice_item_2 = create(:invoice_item, invoice: @customer_6_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 4, status: 0)
    @invoice_item_3 = create(:invoice_item, invoice: @customer_6_invoice_2, item: @merchant_1_item_1, quantity: 1, unit_price: 4, status: 1)

    @customer_1_transaction_1 = create(:transaction, invoice: @customer_1_invoice_1, result: 'success')
    @customer_1_transaction_2 = create(:transaction, invoice: @customer_1_invoice_1, result: 'success')
    @customer_1_transaction_3 = create(:transaction, invoice: @customer_1_invoice_1, result: 'success')
    @customer_1_transaction_4 = create(:transaction, invoice: @customer_1_invoice_2, result: 'success')

    @customer_2_transaction_1 = create(:transaction, invoice: @customer_2_invoice_1, result: 'success')
    @customer_2_transaction_2 = create(:transaction, invoice: @customer_2_invoice_1, result: 'success')

    @customer_3_transaction_1 = create(:transaction, invoice: @customer_3_invoice_1, result: 'success')
    @customer_3_transaction_2 = create(:transaction, invoice: @customer_3_invoice_1, result: 'success')

    @customer_4_transaction_1 = create(:transaction, invoice: @customer_4_invoice_1, result: 'success')
    @customer_4_transaction_2 = create(:transaction, invoice: @customer_4_invoice_1, result: 'success')

    @customer_5_transaction_1 = create(:transaction, invoice: @customer_5_invoice_1, result: 'success')
    @customer_5_transaction_2 = create(:transaction, invoice: @customer_5_invoice_1, result: 'success')

    @customer_6_transaction_1 = create(:transaction, invoice: @customer_6_invoice_1, result: 'success')
    @customer_6_transaction_2 = create(:transaction, invoice: @customer_6_invoice_2, result: 'failed')

    visit merchant_dashboard_index_path(@merchant_1)
  end
  describe 'When I visit /merchants/:merchant_id/dashboard' do
    describe 'Then I see' do
      it 'the name of the merchant' do
        expect(page).to have_content("#{@merchant_1.name}'s Shop")
      end

      it 'a link to merchant items index /merchants/:merchant_id/items' do
        expect(page).to have_link("My Items")
        click_link("My Items")
        expect(current_path).to eq("/merchants/#{@merchant_1.id}/items")
      end

      it 'a link to merchant invoices index /merchants/:merchant_id/invoices' do
        expect(page).to have_link("My Invoices")
        click_link("My Invoices")
        expect(current_path).to eq("/merchants/#{@merchant_1.id}/invoices")
      end

      it 'a list of the merchants top five customers with an item counter next to each one' do
        within "#top-customers-merchant-#{@merchant_1.id}" do
          expect(page).to have_content("#{@customer_1.last_name}, #{@customer_1.first_name}: 3 Transactions")
          expect(page).to have_content("#{@customer_2.last_name}, #{@customer_2.first_name}: 2 Transactions")
          expect(page).to have_content("#{@customer_3.last_name}, #{@customer_3.first_name}: 2 Transactions")
          expect(page).to have_content("#{@customer_4.last_name}, #{@customer_4.first_name}: 2 Transactions")
          expect(page).to have_content("#{@customer_5.last_name}, #{@customer_5.first_name}: 2 Transactions")
          expect(page).to_not have_content("#{@customer_6.last_name}, #{@customer_6.first_name}")
        end
      end

      describe 'a section for items ready to ship' do
        it 'listing all the names of items that have been "ordered" and NOT "shipped"' do
          within "#items-to-ship-merchant-#{@merchant_1.id}" do
            expect(page).to have_content(@merchant_1_item_1.name)
            expect(page).to_not have_content(@merchant_1_item_not_ordered.name)
            expect(page).to_not have_content(@merchant_2_item_1.name)
          end
        end

        it 'next to each listed item is the id of the invoice that ordered it' do
          within "#items-to-ship-merchant-#{@merchant_1.id}" do
            expect(page).to have_content("#{@merchant_1_item_1.name}: Invoice # #{@customer_6_invoice_1.id}")
            expect(page).to_not have_content("#{@merchant_1_item_1.name}: Invoice # #{@customer_1_invoice_1.id}")
            expect(page).to_not have_content("#{@merchant_1_item_1.name}: Invoice # #{@customer_6_invoice_2.id}")
          end
        end

        describe 'next to each listed item and invoice id is the date that the invoice was created it' do
          it 'formatted as Weekday, Month DD, YYYY' do
            within "#items-to-ship-merchant-#{@merchant_1.id}" do
              expect(@invoice_item_1.invoice_date).to eq("Tuesday, 01 November 2022")
            end
          end
        end

        it 'listed from oldest to newest' do
          customer_7 = create(:customer)
          customer_7_invoice_1 = create(:invoice, customer: customer_7, status: 1)
          create(:invoice_item, invoice: customer_7_invoice_1, item: @merchant_1_item_3, quantity: 1, unit_price: 4, status: 0)
          visit merchant_dashboard_index_path(@merchant_1)

          within "#items-to-ship-merchant-#{@merchant_1.id}" do
            expect(@merchant_1_item_1.name).to appear_before(@merchant_1_item_3.name, only_text: true)
          end
        end

        it 'each invoice_id is a link to invoice show page' do
          within "#items-to-ship-merchant-#{@merchant_1.id}" do
            click_link("Invoice # #{@customer_6_invoice_1.id}")
            expect(current_path).to eq("/merchants/#{@merchant_1.id}/invoices/#{@customer_6_invoice_1.id}")
          end
        end
      end

      describe 'a link to view all discounts' do
        it 'when I click this link, I am taken to the bulk discounts index page' do
          within "#merchant-links" do
            click_link("My Discounts")
            expect(current_path).to eq("/merchants/#{@merchant_1.id}/discounts")
          end
        end
      end
    end
  end
end