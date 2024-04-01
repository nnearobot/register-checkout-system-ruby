# frozen_string_literal: true

require "test_helper"

class TestCashRegister < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::CashRegister::VERSION
  end


  def test_empty_cart
    cash_register = CashRegister::ItemList.new
    assert_equal 0,
      cash_register.net_price
  end


  def test_add_item
    cash_register = CashRegister::ItemList.new
    cash_register.add_item({ SKU: "A", price: 1137 })

    assert_equal 1137, cash_register.total_price
    assert_equal 0, cash_register.discount
    assert_equal 1137, cash_register.net_price
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



end
