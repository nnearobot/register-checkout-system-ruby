# frozen_string_literal: true

require "test_helper"

class TestCashRegister < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::CashRegister::VERSION
  end


  def test_empty_cart
    cash_register = CashRegister::ItemList.new
    assert_equal 0, cash_register.net_price
  end


  def test_add_get_item
    cash_register = CashRegister::ItemList.new
    cash_register.add_item({ SKU: "A", price: 1137 })

    assert_equal 1137, cash_register.total_price
    assert_equal 0, cash_register.discount
    assert_equal 1137, cash_register.net_price

    added_item, count = cash_register.get_item("A")
    assert_equal 1137, added_item[:price]
    assert_equal 1, count

    added_item, count = cash_register.get_item("D")
    assert_nil added_item
    assert_equal 0, count
  end


  # If the promotion rules change, we can should the test case to reflect the new rules

  def test_add_different_items
    items = [
      { SKU: "A", price: 3000 },
      { SKU: "B", price: 2000 },
      { SKU: "C", price: 5000 },
      { SKU: "D", price: 1500 }
    ]

    cash_register = CashRegister::ItemList.new
    items.each do |item|
      cash_register.add_item(item)
    end

    assert_equal 11500, cash_register.total_price
    assert_equal 0, cash_register.discount
    assert_equal 11500, cash_register.net_price
  end

  def test_set_of_A
    item = { SKU: "A", price: 3000 }
    cash_register = CashRegister::ItemList.new

    # 2 * 3000 = 6000
    cash_register.add_item(item).add_item(item)
    assert_equal 6000, cash_register.total_price
    assert_equal 6000, cash_register.net_price
    assert_equal 0, cash_register.discount

    # 3: 7500
    cash_register.add_item(item)
    assert_equal 9000, cash_register.total_price
    assert_equal 7500, cash_register.net_price
    assert_equal 1500, cash_register.discount

    # 4: 7500 + 3000 = 10500
    cash_register.add_item(item)
    assert_equal 12000, cash_register.total_price
    assert_equal 10500, cash_register.net_price
    assert_equal 1500, cash_register.discount

    # 5: 7500 + 3000 + 3000 = 13500
    cash_register.add_item(item)
    assert_equal 15000, cash_register.total_price
    assert_equal 13500, cash_register.net_price
    assert_equal 1500, cash_register.discount

    # 6: 7500 * 2 = 15000 (nov over 15000, so the rule "net_price_over_15000" does not apply)
    cash_register.add_item(item)
    assert_equal 18000, cash_register.total_price
    assert_equal 15000, cash_register.net_price
    assert_equal 3000, cash_register.discount
  end

  def test_set_of_B
    item = { SKU: "B", price: 2000 }
    cash_register = CashRegister::ItemList.new

    # 1: 2000
    cash_register.add_item(item)
    assert_equal 2000, cash_register.total_price
    assert_equal 2000, cash_register.net_price
    assert_equal 0, cash_register.discount

    # 2: 3500
    cash_register.add_item(item)
    assert_equal 4000, cash_register.total_price
    assert_equal 3500, cash_register.net_price
    assert_equal 500, cash_register.discount

    # 3: 3500 + 2000 = 5500
    cash_register.add_item(item)
    assert_equal 6000, cash_register.total_price
    assert_equal 5500, cash_register.net_price
    assert_equal 500, cash_register.discount

    # 4: 3500 * 2 = 7000
    cash_register.add_item(item)
    assert_equal 8000, cash_register.total_price
    assert_equal 7000, cash_register.net_price
    assert_equal 1000, cash_register.discount
  end

  def test_net_price_over_15000
    item = { SKU: "A", price: 3000 }
    cash_register = CashRegister::ItemList.new

    6.times do
      cash_register.add_item(item)
    end
    assert_equal 18000, cash_register.total_price
    assert_equal 15000, cash_register.net_price
    assert_equal 3000, cash_register.discount

    # 7: 15000 + 3000 = 18000; 18000 - 2000 = 16000
    cash_register.add_item(item)
    assert_equal 21000, cash_register.total_price
    assert_equal 16000, cash_register.net_price
    assert_equal 5000, cash_register.discount
  end


=begin
   Basket              | Price
  ---------------------|----------
   A, B, C             | JPY 10000
   B, A, B, A, A       | JPY 11000
   C, B, A, A, D, A, B | JPY 15500
   C, A, D, A, A       | JPY 14000
=end

  def test_from_tech_spec
    items = {
      A: { SKU: "A", price: 3000 },
      B: { SKU: "B", price: 2000 },
      C: { SKU: "C", price: 5000 },
      D: { SKU: "D", price: 1500 },
    }

    cash_register = CashRegister::ItemList.new
    cash_register
    .add_item(items[:A])
    .add_item(items[:B])
    .add_item(items[:C])
    assert_equal 10000, cash_register.net_price

    cash_register = CashRegister::ItemList.new
    cash_register
      .add_item(items[:B])
      .add_item(items[:A])
      .add_item(items[:B])
      .add_item(items[:A])
      .add_item(items[:A])
    assert_equal 11000, cash_register.net_price

    cash_register = CashRegister::ItemList.new
    cash_register
      .add_item(items[:C])
      .add_item(items[:B])
      .add_item(items[:A])
      .add_item(items[:A])
      .add_item(items[:D])
      .add_item(items[:A])
      .add_item(items[:B])
    assert_equal 15500, cash_register.net_price

    cash_register = CashRegister::ItemList.new
    cash_register
      .add_item(items[:C])
      .add_item(items[:A])
      .add_item(items[:D])
      .add_item(items[:A])
      .add_item(items[:A])
    assert_equal 14000, cash_register.net_price
  end

end
