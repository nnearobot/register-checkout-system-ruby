# frozen_string_literal: true

require_relative "cash_register/version"

module CashRegister
  class Error < StandardError; end


  class ItemList
    def initialize
      @items = []
      @net_price = 0
      @discount = 0
    end

    def add_item(item)
      @items << item

      # reset the net price and discount as the items have changed
      @net_price = 0
      @discount = 0
    end

    def total_price
      @items.sum { |item| item[:price] }
    end

    def apply_promotions
      # TODO: apply the promotion rules
      net_price = total_price

      return net_price
    end

    def net_price
      if @net_price == 0
        @net_price = apply_promotions
        @discount = total_price - @net_price
      end

      @net_price
    end

    def discount
      # we should check here the net_price because discount can be 0 even if net_price is calculated
      if @net_price == 0
        @net_price = apply_promotions
        @discount = total_price - @net_price
      end

      @discount
    end

    def to_s
      "Total price: JPY #{total_price}, Discount: JPY #{discount}, Net price: JPY #{net_price}"
    end
  end

end
