# frozen_string_literal: true

require_relative "cash_register/version"

module CashRegister
  class Error < StandardError; end


  class ItemList
    def initialize
      # [{ SKU: "A", price: 3000 }]
      @items = []

      # {A: 1}
      @item_counter = {}

      @net_price = 0
      @discount = 0

      @promotion_campaign = Promotion.new
    end

    def add_item(item)
      @items << item

      # in case of the case-sensitive item SKU, remove downcasing:
      sku = item[:SKU].downcase

      if !@item_counter[sku]
        @item_counter[sku] = {
          count: 0,
          item: item
        }
      end

      @item_counter[sku][:count] += 1

      # reset the net price and discount as the items have changed
      @net_price = 0
      @discount = 0

      self
    end

    def get_item(sku)
      # in case of the case-sensitive item SKU, remove downcasing:
      sku = sku.downcase

      return [nil, 0] if !@item_counter[sku]

      [@item_counter[sku][:item], @item_counter[sku][:count]]
    end

    def total_price
      @items.sum { |item| item[:price] }
    end

    def apply_promotions
      @promotion_campaign.apply(self)
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



  class Promotion
    def initialize
      # The list of methods that called one by one 
      # in the order they are defined to calculate the net price with the promotions.
      # Order is important because the rules can be dependent on each other.
      # If some rule returns true for stop_applying, the rest of the rules are not applied.
      @rules = [
        :set_of_3A,
        :set_of_2B,
        :net_price_over_15000

        # add new rule here then add a method some_rule(item_list, current_net_price) #
      ]
    end

    def apply(item_list)
      net_price = item_list.total_price
      @rules.each do |rule|
        new_price, stop_next_rules = send(rule, item_list, net_price)

        # if the rule makes the price higher, we should proceed to the next rule and not apply this rule (if not, remove the next line)
        next if new_price > net_price

        net_price = new_price

        # if the rule says to stop applying, we should stop
        break if stop_next_rules
      end

      net_price
    end


    #### RULES ####

    # if there are 3 items with SKU "A", the price for all 3 is JPY 7500
    def set_of_3A(item_list, current_net_price)
      item, count = item_list.get_item("A")
      set = 3

      return [current_net_price, false] if count < set

      # calculate how many whole sets of 3 items
      set_count = count / set
      
      # calculate the set price with promotion
      price_with_promotion = set_count * 7500

      # the real set price
      real_price = item[:price] * set_count * set

      # reduce the current net price by the difference between the real price and the price for sets
      current_net_price = current_net_price - (real_price - price_with_promotion)

      [current_net_price, false]
    end


    # If 2 of item B are purchased, the price for both is JPY 3500
    def set_of_2B(item_list, current_net_price)
      item, count = item_list.get_item("B")
      set = 2

      return [current_net_price, false] if count < set

      # calculate how many whole sets of 2 items
      set_count = count / set

      # calculate the set price with promotion
      price_with_promotion = set_count * 3500

      # the real price of all the items
      real_price = item[:price] * set_count * set

      # reduce the current net price by the difference between the real price and the price for sets
      current_net_price = current_net_price - (real_price - price_with_promotion)

      [current_net_price, false]
    end


    # If the total basket price (after previous discounts) is over JPY 15000, the basket receives a discount of JPY 2000.
    def net_price_over_15000(item_list, current_net_price)
      # Let’s assume that if the price is over 15000, this rule needs to be applied last,
      # ensuring that no further actions are taken after its application.
      # (Because the price can be reduced to less than 15000 after applying the previous rules.)
      stop_next_rules = false
      if current_net_price > 15000
        current_net_price -= 2000
        stop_next_rules = true
      end

      [current_net_price, stop_next_rules]
    end

  end

end
