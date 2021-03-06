class ItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :search]
  def search
    @items = Item.all

    if params[:search]
      @items = Item.search(params[:search])
    else
      @items = Item.all
    end
  end

  def index
   @items = Item.all.joins(:user).where.not(users: {latitude: nil})
   @items = @items.joins('LEFT OUTER JOIN bookings ON bookings.item_id = items.id').where('bookings.item_id IS NULL')
    if params[:search]
      @items = @items.where("name LIKE ?", "%#{params[:search].capitalize}%")
      # @items = @items.all.where("name LIKE ?", "%#{params[:search].capitalize}%")
      # @items = Item.all.joins(:user).where.not(users: {latitude: nil}) #items of the user where longitude and latitude not nil
    else
      @items
      # = Item.all.joins(:user).where.not(users: {latitude: nil})
    end
    @hash = Gmaps4rails.build_markers(@items) do |item, marker|
      marker.lat item.user.latitude
      marker.lng item.user.longitude
    end
  end

  def show
    @item = Item.find(params[:id])
    @reviews = @item.user.reviews
    @review = Review.new  # <-- You need this now
     @seller = @item.user
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    @item.user = current_user

    @item.latitude = current_user.latitude
    @item.longitude = current_user.longitude

    if @item.save
      redirect_to item_path(@item)
    else
      render :new
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :good_until, :category, :quantity, :indicator,:price, :description, :photo)
  end
end

