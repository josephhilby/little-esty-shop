class BulkDiscount < ApplicationRecord
  belongs_to :merchant 
  has_many :invoice_items

  validates_presence_of :threshold, :discount
  validates_numericality_of :discount, only_integer: true, greater_than: 0, less_than: 100
  validates_numericality_of :threshold, only_integer: true, greater_than: 0
  validate :can_be_applied, if: Proc.new { |d| d.discount.present? && d.threshold.present? }

  def can_be_applied
    return unless BulkDiscount.any? 
    highest_discount = BulkDiscount.order(discount: :desc).first 
    if discount < highest_discount.discount && threshold > highest_discount.threshold
      errors.add(:discount, "is less than the current highest discount, but with a greater threshold, and will never be applied")
    end
  end
end