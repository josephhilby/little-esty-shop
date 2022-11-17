require "rails_helper"


RSpec.describe Merchant, type: :model do
  describe "Relationships" do
    it { should have_many(:items) }
    it { should have_many(:discounts) }
  end

  before(:each) do
    @merchant_1 = create(:merchant, status: 0)
    @merchant_1_item_1 = create(:item, merchant: @merchant_1, status: 0)
    @merchant_1_item_2 = create(:item, merchant: @merchant_1, status: 0)
    @merchant_1_item_3 = create(:item, merchant: @merchant_1, status: 1)
    @merchant_1_item_4 = create(:item, merchant: @merchant_1, status: 1)
    @merchant_1_item_5 = create(:item, merchant: @merchant_1, status: 1)
    @merchant_1_item_6 = create(:item, merchant: @merchant_1, status: 1)

    @merchant_2 = create(:merchant, status:1)
    @merchant_2_item_1 = create(:item, merchant: @merchant_2, status: 0)
    @merchant_2_item_2 = create(:item, merchant: @merchant_2, status: 1)

    @march_third = DateTime.new(2022, 3, 3, 6, 2, 3)
    @customer_1 = create(:customer)
    @customer_1_invoice_1 = create(:invoice, customer: @customer_1, created_at: @march_third, status: 2)
    @customer_1_invoice_2 = create(:invoice, customer: @customer_1, status: 2)

    @customer_2 = create(:customer)
    @customer_2_invoice_1 = @customer_2.invoices.create!(status: 2)
    @customer_2_invoice_2 = @customer_2.invoices.create!(status: 2)

    @customer_1_invoice_1_item_1_packaged = create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 1, status: 0)
    @customer_1_invoice_1_item_1_shipped = create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 1, status: 2)
    @customer_1_invoice_2_item_1_merchant_2 = create(:invoice_item, invoice: @customer_1_invoice_2, item: @merchant_2_item_1, status: 0)
    @customer_2_invoice_1_item_1_packaged = create(:invoice_item, invoice: @customer_2_invoice_1, item: @merchant_1_item_1, quantity: 1, unit_price: 1, status: 0)
  end

  describe "Instance Methods" do
    describe "#enabled_items" do
      it "returns a collection of the enabled items for the merchant instance" do
        expect(@merchant_1.enabled_items.to_a).to eq([@merchant_1_item_1, @merchant_1_item_2])
      end
    end

    describe "#invoice_items_to_ship" do
      describe "returns an array of invoice_items" do
        it "where invoice_item is \"packaged\" (0)" do
          expect(@merchant_1.invoice_items_to_ship).to eq([@customer_1_invoice_1_item_1_packaged, @customer_2_invoice_1_item_1_packaged])
        end

        it "ordered by invoice created_at, NOT invoice_item created_at" do
          customer_1_invoice_1 = create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1, status: 0)
          expect(@merchant_1.invoice_items_to_ship).to eq([@customer_1_invoice_1_item_1_packaged, customer_1_invoice_1, @customer_2_invoice_1_item_1_packaged])
        end
      end
    end

    describe "#disabled_items" do
      it "returns an array of disabled items for that merchant instance" do
        expect(@merchant_1.disabled_items).to eq([@merchant_1_item_3, @merchant_1_item_4, @merchant_1_item_5, @merchant_1_item_6])
      end
    end

    describe 'Top revenue items and days' do
      before(:each) do
        10.times {create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_1, quantity: 10, unit_price: 10, status: 0)}
        9.times {create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_2, quantity: 10, unit_price: 10,status: 0)}
        8.times {create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_3, quantity: 10, unit_price: 10,status: 0)}
        7.times {create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_4, quantity: 10, unit_price: 10,status: 0)}
        6.times {create(:invoice_item, invoice: @customer_1_invoice_1, item: @merchant_1_item_5, quantity: 10, unit_price: 10,status: 0)}
        create(:transaction, invoice: @customer_1_invoice_1, result: 'success')
      end

      describe "#top_five_items" do
        it "returns a collection of items, including their total revenue, of the top five items for that merchant" do
          expect(@merchant_1.top_five_items).to eq([@merchant_1_item_1, @merchant_1_item_2, @merchant_1_item_3, @merchant_1_item_4, @merchant_1_item_5])
          expect(@merchant_1.top_five_items[0].total_revenue).to(eq(1002))
          expect(@merchant_1.top_five_items[1].total_revenue).to(eq(900))
          expect(@merchant_1.top_five_items[2].total_revenue).to(eq(800))
          expect(@merchant_1.top_five_items[3].total_revenue).to(eq(700))
          expect(@merchant_1.top_five_items[4].total_revenue).to(eq(600))
        end
      end

      describe "#top_day" do
        it "returns the DateTime for merchants top revenue day" do
          expect(@merchant_1.top_day).to(eq(@march_third))
        end
      end
    end
  end

  describe "Class Method" do
    describe ".top_five_merchants" do
      it "can check top 5 merchants" do
        customer = create(:customer)
        invoice_1 = create(:invoice, customer: customer)
        invoice_2 = create(:invoice, customer: customer)
        merchant_1 = create(:merchant)
        item_1 = create(:item, merchant: merchant_1)
        create(:invoice_item, invoice: invoice_1, item: item_1, quantity: 10, unit_price:10)
        create(:invoice_item, invoice: invoice_2, item: item_1, quantity: 5, unit_price:100)
        merchant_2 = create(:merchant)
        item_2 = create(:item, merchant: merchant_2)
        create(:invoice_item, invoice: invoice_1, item: item_2, quantity: 9, unit_price:10)
        create(:invoice_item, invoice: invoice_2, item: item_2, quantity: 6, unit_price:100)
        merchant_3 = create(:merchant)
        item_3 = create(:item, merchant: merchant_3)
        create(:invoice_item, invoice: invoice_1, item: item_3, quantity: 8, unit_price:10)
        create(:invoice_item, invoice: invoice_2, item: item_3, quantity: 7, unit_price:100)
        merchant_4 = create(:merchant)
        item_4 = create(:item, merchant: merchant_4)
        create(:invoice_item, invoice: invoice_1, item: item_4, quantity: 7, unit_price:10)
        create(:invoice_item, invoice: invoice_2, item: item_4, quantity: 8, unit_price:100)
        merchant_5 = create(:merchant)
        item_5 = create(:item, merchant: merchant_5)
        create(:invoice_item, invoice: invoice_1, item: item_5, quantity: 6, unit_price:10)
        create(:invoice_item, invoice: invoice_2, item: item_5, quantity: 9, unit_price:100)
        merchant_6 = create(:merchant)
        item_6 = create(:item, merchant: merchant_6)
        create(:invoice_item, invoice: invoice_1, item: item_6, quantity: 5, unit_price:10)
        create(:invoice_item, invoice: invoice_2, item: item_6, quantity: 10, unit_price:100)
        create(:transaction, invoice: invoice_1, result: 'success')
        create(:transaction, invoice: invoice_2, result: 'failure')

        expect(Merchant.top_five_merchants).to eq([merchant_1, merchant_2, merchant_3, merchant_4, merchant_5])
      end
    end

    describe ".enabled_merchants" do
      it "returns collection of enabled merchants" do
        expect(Merchant.enabled_merchants).to eq([@merchant_1])
      end
    end

    describe ".disabled_merchants" do
      it "returns collection of disabled merchants" do
        expect(Merchant.disabled_merchants).to(eq([@merchant_2]))
      end
    end

    describe ".items_by_invoice" do
      it 'returns an array of the merchants items by select invoice' do
        merchant_1 = create(:merchant)
        item_1 = create(:item, merchant: merchant_1)
        item_2 = create(:item, merchant: merchant_1)
        merchant_2 = create(:merchant)
        item_3 = create(:item, merchant: merchant_2)
        customer = create(:customer)
        invoice_1 = create(:invoice, customer: customer)
        create(:invoice_item, invoice: invoice_1, item: item_1)
        create(:invoice_item, invoice: invoice_1, item: item_3)
        invoice_2 = create(:invoice, customer: customer)
        create(:invoice_item, invoice: invoice_2, item: item_2)

        expect(merchant_1.items_by_invoice(invoice_1)).to eq([item_1])
      end
    end
  end
end