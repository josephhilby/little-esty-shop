class BulkDiscount < ApplicationRecord
  belongs_to :merchant 
  has_many :invoice_items

  validates_presence_of :threshold, :discount
  validates_numericality_of :discount, only_integer: true, greater_than: 0, less_than: 100
  validates_numericality_of :threshold, only_integer: true, greater_than: 0
end