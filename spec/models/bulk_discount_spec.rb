require "rails_helper"

RSpec.describe BulkDiscount type: :model do 
  describe "Relationships" do 
    it { should belong_to :merchant }
  end

  describe "Validations" do 
    it { should validate_numericality_of(:discount).is_greater_than(0).is_less_than(100).only_integer }
    it { should validate_numericality_of(:threshold).only_integer }
    it { should validate_presence_of :discount, :threshold }
  end
end