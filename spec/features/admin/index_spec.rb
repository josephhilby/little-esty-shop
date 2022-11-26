require 'rails_helper'

RSpec.describe 'admin index page' do
  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @merchant_1_item_1 = create(:item, merchant: @merchant_1)
    @merchant_1_item_not_ordered = create(:item, merchant: @merchant_1)
    @merchant_1_item_2 = create(:item, merchant: @merchant_1)
    @merchant_2_item_1 = create(:item, merchant: @merchant_2)

    @customer_1 = create(:customer)
    @customer_2 = create(:customer)
    @customer_3 = create(:customer)
    @customer_4 = create(:customer)
    @customer_5 = create(:customer)
    @customer_6 = create(:customer)

    @date_1 = DateTime.new(2022,12,27,0,4,2)
    @date_2 = DateTime.new(2022,01,31,0,4,2)
    @date_3 = DateTime.new(2022,10,27,0,4,2)

    @customer_1_invoice_1 = create(:invoice, customer: @customer_1, status: 1)
    @customer_1_invoice_2 = create(:invoice, customer: @customer_1, status: 1)
    @customer_1_invoice_3 = create(:invoice, customer: @customer_1, status: 2, created_at: @date_2)

    @customer_2_invoice_1 = create(:invoice, customer: @customer_2, status: 1)
    @customer_2_invoice_2 = create(:invoice, customer: @customer_2, status: 2, created_at: @date_3)

    @customer_3_invoice_1 = create(:invoice, customer: @customer_3, status: 1)
    @customer_4_invoice_1 = create(:invoice, customer: @customer_4, status: 1)
    @customer_5_invoice_1 = create(:invoice, customer: @customer_5, status: 1)
    @customer_6_invoice_1 = create(:invoice, customer: @customer_6, status: 1)
    @customer_6_invoice_2 = create(:invoice, customer: @customer_6, status: 2, created_at: @date_1)

    create(:invoice_item, invoice: @customer_1_invoice_2, item: @merchant_2_item_1, quantity: 1, unit_price: 4, status: 0)
    create(:invoice_item, invoice: @customer_2_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 3, status: 2)
    create(:invoice_item, invoice: @customer_3_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 3, status: 2)
    create(:invoice_item, invoice: @customer_4_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 3, status: 2)
    create(:invoice_item, invoice: @customer_5_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 3, status: 2)

    @invoice_item_1 = create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 3, status: 2)
    @invoice_item_2 = create(:invoice_item, invoice: @customer_6_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 7, status: 0)
    @invoice_item_3 = create(:invoice_item, invoice: @customer_6_invoice_2, item: @merchant_1_item_1, quantity: 1, unit_price: 7, status: 1)

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

    visit admin_path
  end

  describe 'admin header' do
    it 'displays admin header' do
      expect(page).to have_content("Admin Dashboard")
    end
  end

  describe 'admin invoice link' do
    it 'displays links to admin invoices' do
      expect(page).to have_link "Merchants"
    end
  end

  describe 'admin invoice link' do
    it 'displays links to admin invoices' do
      expect(page).to have_link "Invoices"
    end
  end

  describe 'admin top customers' do
    it 'displays names of top 5 customers who conducted largest # of successful transactions with count listed' do
      expect(page).to have_content("Top 5 Customers")

      within "#top-5-customers" do
        expect(@customer_1.first_name).to appear_before(@customer_2.first_name)
        expect(@customer_2.first_name).to appear_before(@customer_3.first_name)
        expect(@customer_3.first_name).to appear_before(@customer_4.first_name)
        expect(@customer_4.first_name).to appear_before(@customer_5.first_name)
        expect(@customer_5.first_name).to_not appear_before(@customer_4.first_name)
      end
    end
  end

  describe 'incomplete invoices' do
    it 'displays a list of ids of all invoices that have items not yet shipped-id links to that invoices admin show page' do
      within "#incomplete-invoices" do
        expect(page).to have_content("Incomplete Invoices")
        expect(page).to have_content(@customer_6_invoice_2.id)

        click_link "Invoice #{@customer_6_invoice_2.id}"
        expect(current_path).to eq("/admin/invoices/#{@customer_6_invoice_2.id}")
      end
    end

    it 'shows the incomplete invoices ordered from oldest to newest' do
      within "#incomplete-invoices" do
        expect("Monday, January 31, 2022").to appear_before("Thursday, October 27, 2022", only_text: true)
        expect("Thursday, October 27, 2022").to appear_before("Tuesday, December 27, 2022", only_text: true)
        expect("Tuesday, December 27, 2022").to_not appear_before("Monday, January 31, 2022", only_text: true)
      end
    end
  end
end

