class Invoice < ApplicationRecord
 
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  enum status: ["Cancelled", "Completed", "In Progress"]

  def self.invoices_for(merchant)
    invoice_ids = merchant.invoice_items.pluck("invoice_id")
    Invoice.where(id: invoice_ids)
  end

  def customer_last
    self.customer.last_name
  end

  def customer_first
    self.customer.first_name
  end

  def total_revenue
    self.items.sum(:unit_price)
  end

  def self.incomplete_invoices
    where(status: "In Progress").order(:created_at)
  end

  def invoice_revenue 
    self.invoice_items.sum("quantity * unit_price")
  end
end


