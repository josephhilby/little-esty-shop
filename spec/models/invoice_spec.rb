require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "Relationships" do
    it { should belong_to(:customer) }
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
  end

  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @merchant_3 = create(:merchant)

    @merchant_1_item_1 = create(:item, merchant: @merchant_1)
    @merchant_1_item_not_ordered = create(:item, merchant: @merchant_1)
    @merchant_1_item_2 = create(:item, merchant: @merchant_1)
    @merchant_2_item_1 = create(:item, merchant: @merchant_2)
    @merchant_3_item_1 = create(:item, merchant: @merchant_3)

    @customer_1 = create(:customer)
    @customer_2 = create(:customer)
    @customer_3 = create(:customer)
    @customer_4 = create(:customer)
    @customer_5 = create(:customer)
    @customer_6 = create(:customer)

    @customer_1_invoice_1 = create(:invoice, customer: @customer_1, status: 1)
    @customer_1_invoice_2 = create(:invoice, customer: @customer_1, status: 1)

    create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 3, status: 1)
    create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_2, quantity: 4, unit_price: 6, status: 1)

    @customer_2_invoice_1 = create(:invoice, customer: @customer_2, status: 1)
    @customer_3_invoice_1 = create(:invoice, customer: @customer_3, status: 1)
    @customer_4_invoice_1 = create(:invoice, customer: @customer_4, status: 1)
    @customer_5_invoice_1 = create(:invoice, customer: @customer_5, status: 1)

    @customer_6_invoice_1 = create(:invoice, customer: @customer_6, status: 1)
    @customer_6_invoice_2 = create(:invoice, customer: @customer_6, status: 2)

    create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1)
    create(:invoice_item, invoice: @customer_1_invoice_2, item: @merchant_1_item_1)
    create(:invoice_item, invoice: @customer_2_invoice_1, item: @merchant_2_item_1)
    create(:invoice_item, invoice: @customer_2_invoice_1, item: @merchant_2_item_1)
    create(:invoice_item, invoice: @customer_2_invoice_1, item: @merchant_2_item_1)
    create(:invoice_item, invoice: @customer_6_invoice_1, item: @merchant_2_item_1, quantity: 1, unit_price: 10)
    create(:invoice_item, invoice: @customer_6_invoice_1, item: @merchant_2_item_1, quantity: 1, unit_price: 10)
    create(:invoice_item, invoice: @customer_6_invoice_1, item: @merchant_3_item_1, quantity: 2, unit_price: 15)

    create(:transaction, invoice: @customer_6_invoice_1, result: "success")
  end

  describe 'Class Methods' do
    describe '.incomplete_invoices' do
      it 'returns the invoices that are still in progress' do
        expect(Invoice.incomplete_invoices).to eq([@customer_6_invoice_2])
      end
    end


    describe ".invoices_for" do
      it 'selects all invoices assoicated with that merchant' do
        expect(Invoice.invoices_for(@merchant_1).to_a).to eq([@customer_1_invoice_1, @customer_1_invoice_2])
      end
    end
  end

  describe "Instance Methods" do
    describe '#customer_last' do
      it 'returns the invoiced customers last name' do
        expect(@customer_1_invoice_1.customer_last).to eq(@customer_1.last_name)
      end
    end

    describe '#customer_first'do
      it 'returns the invoiced customers first name' do
        expect(@customer_1_invoice_1.customer_first).to eq(@customer_1.first_name)
      end
    end

    describe '#total_revenue' do
      it 'returns the sum of all items (unit_cost * quantity) on that invoice, for that merchant' do
        expect(@customer_6_invoice_1.total_revenue(@merchant_2)).to eq(20)
      end
    end

    describe '#invoice_revenue' do
      it 'returns total revenue for specific invoices' do
        expect(@customer_1_invoice_1.invoice_revenue).to eq(27)
      end
    end
  end
end
