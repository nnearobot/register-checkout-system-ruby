# Checkout System

This is a Ruby gem that represents a checkout system that meets the following requirements:

- It can scan items.
- It can compute the total price.
- It can apply promotion campaigns, which are configurable.

We assume that items with the same SKU have identical prices. If not, the price for a product with a particular SKU is based on the first occurrence of this item.

Please check the files `lib/cash_register.rb` and `test/test_cash_register.rb` for the code reference.


## Usage

Please refer to the example of the usage described below.

```ruby
cash_register = CashRegister::ItemList.new
cash_register
  .add_item({ SKU: "A", price: 3000 })
  .add_item({ SKU: "B", price: 2000 })
  .add_item({ SKU: "C", price: 5000 })

puts cash_register # Total price: JPY 10000, Discount: JPY 0, Net price: 10000
```


## Tests

To run the rests please from the gem's root directory run:
```bash
rake test
```


## Areas to improve


### Use type checker

We can use a type checker like Stripe's Sorbet for checking that `item` is an instance of the object with the particular properties (here `SKU` and `price`).


### Deleting an item from the list

Sometimes, if a cashier scans an item by mistake, they may want to delete it. Therefore, we can implement a function to delete an item from the list in the ItemList class.

However, if this item should be represented on the receipt as struck through, we should not delete this item from the list entirely, but just mark it as deleted.

A marked deleted item should not be included in the calculation of promotions and the net price.


### Total price calculation

We may calculate the total price while adding new items.

However, this method is not reliable, as something can go wrong during the addition, and the total price may not be updated. This could lead to data inconsistency.

Therefore, we calculate the total price by summing the prices of the items only when it is needed.


### Check if the promotion campaign reduce the price

We aim for the promotional campaign to reduce (or at least maintain) the total price of the items. Therefore, each time we apply a promotional rule, we should verify whether the new price is higher. If it is, we should not apply this rule.

However, there may be instances where we wish to apply rules that increase the price (for specific business needs, why not?). If that's the case, we should remove the following line from the `apply_rules` method:

```ruby
next if new_price > net_price
```
