require "rails_helper"
require "date"


RSpec.describe("On the Merchant's Items index page") do
  before(:each) do
    @merchant = create(:merchant)

    @item_1 = create(:item, merchant: @merchant)
    @item_2 = create(:item, merchant: @merchant)
    @item_3 = create(:item, merchant: @merchant)
    @item_4 = create(:item, merchant: @merchant)
    @item_5 = create(:item, merchant: @merchant)
    @item_6 = create(:item, merchant: @merchant)

    @other_merchant = create(:merchant)

    @item_7 = create(:item, merchant: @other_merchant)
    @item_8 = create(:item, merchant: @other_merchant)

    customer = create(:customer)

    feb_third = DateTime.new(2022, 2, 3, 4, 5, 6)
    march_third = DateTime.new(2022, 3, 3, 6, 2, 3)
    april_first = DateTime.new(2022, 4, 1, 8, 9, 6)

    invoice_1 = create(:invoice, customer: customer, status: 1, created_at: feb_third)
    invoice_2 = create(:invoice, customer: customer, status: 1, created_at: march_third)
    invoice_3 = create(:invoice, customer: customer, status: 1, created_at: april_first)

    create(:invoice_item, invoice: invoice_1, item: @item_1, quantity: 2, unit_price: 4, status: 2)
    create(:invoice_item, invoice: invoice_1, item: @item_2, quantity: 2, unit_price: 15, status: 2)
    create(:invoice_item, invoice: invoice_2, item: @item_3, quantity: 2, unit_price: 10, status: 2)
    create(:invoice_item, invoice: invoice_2, item: @item_4, quantity: 2, unit_price: 9, status: 2)
    create(:invoice_item, invoice: invoice_2, item: @item_5, quantity: 1, unit_price: 2, status: 2)
    create(:invoice_item, invoice: invoice_3, item: @item_6, quantity: 1, unit_price: 3, status: 0)
    create(:invoice_item, invoice: invoice_3, item: @item_4, quantity: 6, unit_price: 9, status: 0)

    create(:transaction, invoice: invoice_1, result: "success")
    create(:transaction, invoice: invoice_1, result: "failed")
    create(:transaction, invoice: invoice_2, result: "success")
    create(:transaction, invoice: invoice_3, result: "failed")

    visit merchant_items_path(@merchant)
  end

  describe "When I visit merchants/:merchant_id/items" do
    it "displays a list of the names of all my items and I do not see items for any other merchant" do
      within "#disabled" do
        within "#item-#{@item_1.id}" do
          expect(page).to have_content(@item_1.name)
        end

        within "#item-#{@item_2.id}" do
          expect(page).to have_content(@item_2.name)
        end

        within "#item-#{@item_3.id}" do
          expect(page).to have_content(@item_3.name)
        end

        within "#item-#{@item_4.id}" do
          expect(page).to have_content(@item_4.name)
        end

        within "#item-#{@item_5.id}" do
          expect(page).to have_content(@item_5.name)
        end

        within "#item-#{@item_6.id}" do
          expect(page).to have_content(@item_6.name)
        end
      end

      expect(page).to_not have_content(@item_7.name)
      expect(page).to_not have_content(@item_8.name)
    end

    it "when I click on the name of an item from the index page, I am taken to the show page" do
      expect(page).to have_link(@item_1.name, href: merchant_item_path(@merchant, @item_1))
      expect(page).to have_link(@item_2.name, href: merchant_item_path(@merchant, @item_2))
      expect(page).to have_link(@item_3.name, href: merchant_item_path(@merchant, @item_3))

      within("#disabled") do
        within("#item-#{@item_1.id}") do
          click_on(@item_1.name)
        end
      end

      expect(current_path).to eq(merchant_item_path(@merchant, @item_1))
    end

    it("displays items grouped by status and disable/enable buttons for each item, when clicked, reloads index and the items status is changed") do
      within("#disabled") do
        within("#item-#{@item_1.id}") do
          expect(page).to(have_button("Enable"))
        end

        within("#item-#{@item_2.id}") do
          expect(page).to(have_button("Enable"))
        end

        within("#item-#{@item_3.id}") do
          expect(page).to(have_button("Enable"))
          click_button("Enable")
        end
      end

      expect(current_path).to eq(merchant_items_path(@merchant))

      within("#disabled") do
        within("#item-#{@item_1.id}") do
          expect(page).to have_button("Enable")
        end

        within("#item-#{@item_2.id}") do
          expect(page).to have_button("Enable")
        end
      end

      within("#enabled") do
        within("#item-#{@item_3.id}") do
          expect(page).to(have_button("Disable"))
          click_button("Disable")
        end
      end

      expect(current_path).to(eq(merchant_items_path(@merchant)))

      within("#disabled") do
        within("#item-#{@item_1.id}") do
          expect(page).to(have_button("Enable"))
        end

        within("#item-#{@item_2.id}") do
          expect(page).to(have_button("Enable"))
        end

        within("#item-#{@item_3.id}") do
          expect(page).to(have_button("Enable"))
        end
      end
    end

    it "has a link to 'New Item' which takes me to a form to create a new item" do
      expect(page).to(have_link("New Item", href: new_merchant_item_path(@merchant)))
      click_on("New Item")
      expect(current_path).to(eq(new_merchant_item_path(@merchant)))
    end

    it "displays the names of the top 5 most popular items ranked by total revenue generated. Each name links to the item's show page" do
      within("#top-items") do
        expect("#{@item_2.name}: $30.00").to appear_before("#{@item_3.name}: $20.00 in sales", only_text: true)
        expect("#{@item_3.name}: $20.00 in sales").to appear_before("#{@item_4.name}: $18.00 in sales", only_text: true)
        expect("#{@item_4.name}: $18.00 in sales").to appear_before("#{@item_1.name}: $8.00 in sales", only_text: true)
        expect("#{@item_1.name}: $8.00 in sales").to appear_before("#{@item_5.name}: $2.00 in sales", only_text: true)
        expect(page).to have_link(@item_2.name, href: merchant_item_path(@merchant, @item_2))
        expect(page).to have_link(@item_3.name, href: merchant_item_path(@merchant, @item_3))
        expect(page).to have_link(@item_4.name, href: merchant_item_path(@merchant, @item_4))
        expect(page).to have_link(@item_1.name, href: merchant_item_path(@merchant, @item_1))
        expect(page).to have_link(@item_5.name, href: merchant_item_path(@merchant, @item_5))
      end
    end

    it("displays the date with the most sales for each item with label 'Top selling date for <item> was <date>'") do
      within("#top-items") do
        expect(page).to(have_content("Top selling date for #{@item_2.name} was 2/3/22"))
        expect(page).to(have_content("Top selling date for #{@item_3.name} was 3/3/22"))
        expect(page).to(have_content("Top selling date for #{@item_4.name} was 3/3/22"))
        expect(page).to(have_content("Top selling date for #{@item_1.name} was 2/3/22"))
        expect(page).to(have_content("Top selling date for #{@item_5.name} was 3/3/22"))
      end
    end
  end

  describe("Wireframe requirements for merchants items index page") do
    it("has the little esty shop heading, nav bar, My Items header, and merchant's name") do
      expect(page).to(have_content("Little Esty Shop"))
      expect(page).to(have_content(@merchant.name))
      expect(page).to(have_content("Dashboard"))
      expect(page).to(have_content("My Items"))
      expect(page).to(have_content("My Invoices"))
    end
  end
end
