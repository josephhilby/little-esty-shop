require 'rails_helper'
require 'date'

RSpec.describe 'On the Merchant Invoices Index Page' do
  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @merchant_1_item_1 = create(:item, merchant: @merchant_1)
    @merchant_2_item_1 = create(:item, merchant: @merchant_2)

    @customer_1 = create(:customer)
    @customer_2 = create(:customer)
    @customer_3 = create(:customer)

    @customer_1_invoice_1 = create(:invoice, customer: @customer_1, status: 1)
    @customer_1_invoice_2 = create(:invoice, customer: @customer_1, status: 1)
    @customer_2_invoice_1 = create(:invoice, customer: @customer_2, status: 1)
    @customer_3_invoice_1 = create(:invoice, customer: @customer_3, status: 1)

    create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1)
    create(:invoice_item, invoice: @customer_1_invoice_2, item: @merchant_1_item_1)
    create(:invoice_item, invoice: @customer_2_invoice_1, item: @merchant_1_item_1)
    create(:invoice_item, invoice: @customer_3_invoice_1, item: @merchant_2_item_1)

    visit merchant_invoices_path(@merchant_1)
  end
  describe 'When I visit /merchants/:merchant_id/invoices' do
    describe 'Then I see' do
      it 'all the invoices and invoice_ids that include at least one of the merchants items' do
        expect(page).to have_content("Invoice # #{@customer_1_invoice_1.id}")
        expect(page).to have_content("Invoice # #{@customer_1_invoice_2.id}")
        expect(page).to have_content("Invoice # #{@customer_2_invoice_1.id}")
        expect(page).to_not have_content("Invoice # #{@customer_3_invoice_1.id}")
      end

      it 'each invoice_id is a link to that invoice show page' do
        visit "/merchants/#{@merchant_1.id}/invoices"
        click_link "#{@customer_1_invoice_1.id}"
        expect(current_path).to eq("/merchants/#{@merchant_1.id}/invoices/#{@customer_1_invoice_1.id}")
      end
    end
  end
end