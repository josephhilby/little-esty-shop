class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  belongs_to :bulk_discount, optional: true 
  enum status: ["packaged", "pending", "shipped"]
  after_initialize :add_discount

  def item_name
    Item.find(self.item_id).name
  end

  def invoice_date
    Invoice.find(self.invoice_id).created_at.strftime("%A, %d %B %Y")
  end

  def find_discount
    item.merchant.bulk_discounts.where("#{quantity} >= bulk_discounts.threshold").order(threshold: :desc).first
  end

  def add_discount 
    update(bulk_discount: find_discount)
  end
end