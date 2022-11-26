require "rails_helper"

RSpec.describe "Admin Merchants Index Page" do
  before(:each) do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @merchant_3 = create(:merchant)
    visit admin_merchants_path
  end

  describe "Admin merchants index" do
    it "Displays name of each merchant in the system" do
      expect(page).to have_content(@merchant_1.name)
      expect(page).to have_content(@merchant_2.name)
      expect(page).to have_content(@merchant_3.name)
    end
  end

  describe "I click on the name of a merchant from the admin merchants index page" do
    it "I am taken to that merchant's admin show page (/admin/merchants/merchant_id)" do
      click_link("#{@merchant_1.name}")
      expect(current_path).to eq(admin_merchant_path(@merchant_1.id))
      expect(page).to have_content("Name: #{@merchant_1.name}")
    end

    it "And I see the name of that merchant" do
      click_link("#{@merchant_1.name}")
      expect(current_path).to eq(admin_merchant_path(@merchant_1.id))
      expect(page).to(have_content("Name: #{@merchant_1.name}"))
    end
  end
end
