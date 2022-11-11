class AddBulkDiscountToInvoiceItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoice_items, :bulk_discount, foreign_key: true, default: nil
  end
end
