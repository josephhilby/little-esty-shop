class InvoicesController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @invoices = Invoice.invoices_for(@merchant)
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @invoice = Invoice.find(params[:id])
    @items = @invoice.invoice_items.joins(:item).where("items.merchant_id = #{@merchant.id}")
  end
end