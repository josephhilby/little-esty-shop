class Merchant < ApplicationRecord
  has_many :items
  has_many :invoice_items,   through: :items
  has_many :invoices,   through: :invoice_items
  has_many :customers,   through: :invoices
  has_many :transactions,   through: :invoices
  enum   status: ["enabled", "disabled"]

  def invoice_items_to_ship
    self.invoice_items.joins(:invoice).where(    status: 0).order("invoices.created_at")
  end

  def enabled_items
    items.where(    status: "enabled")
  end

  def disabled_items
    items.where(    status: "disabled")
  end

  def top_five_items
    items.joins(    invoices: :transactions).where(    transactions: {result: "success"}).group(:id).select("items.*, sum(invoice_items.unit_price * invoice_items.quantity) as total_revenue").order(    total_revenue: :desc).limit(5)
  end

  def self.enabled_merchants
    self.where(    status: "enabled")
  end

  def self.disabled_merchants
    self.where(    status: "disabled")
  end
end
