class ItemsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @enabled_items = @merchant.enabled_items
    @disabled_items = @merchant.disabled_items
    @top_items = @merchant.top_five_items
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @item = Item.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    merchant.items.create(app_params)

    redirect_to merchant_items_path(merchant)
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @item = Item.find(params[:id])
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    item = Item.find(params[:id])
    if params[:status]
      item.update(status: params[:status])
      redirect_to merchant_items_path(merchant)
    else
      item.update(app_params)
      flash[:alert] = "This item's information has been successfully updated!"
      redirect_to merchant_item_path(merchant, item)
    end
  end

  private
  def app_params
    params.permit(:merchant_id, :id, :name, :description, :unit_price)
  end
end