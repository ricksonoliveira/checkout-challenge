# Checkout

Checkout is a microservice that implements business rules on shopping discounts, where you can configure cutsom discounts previously on the `products.json` file for the system to implement.

Developed with pure [Elixir](https://elixir-lang.org/).

*Challenged by: [Horizon 65](https://horizon65.com/en/).*

## Installation

All you need to do is:

* Clone the repo
* `mix deps.get` it
* Open terminal inside root dir and type `iex -S mix` for iterative mode

Aaand... voilá! ✨  Easy as that.

## Usage

The plan here is that the user should make shopping fast, so you just have to scan the products you want, and let the microservice do the hard work.

The products available in our "stock" are: Voucher (VOUCHER) 🎫, T-shirt (TSHIRT) 👕 and Coffee Mug (MUG) ☕️.

In order to buy them, you have to type their code, which are the the caps lock letters above 👆🏻.

So, inside the iterative mode terminal, type the scan fuction along with the product code, and it will be added to our virtual cart that is stored in a local file the system will create automaticaly, to keep your cart saved as kind of a session.

```
iex(1)> Checkout.scan("VOUCHER")
{:ok,
 %{
   cart: [%{code: "VOUCHER", name: "Voucher", price: 5.0}],
   discount: "0.00",
   total: "5.00€"
 }}
```

As can be seen above, we scanned a voucher, and the return we had was an `:ok` followed by the product info. Which means it was successfully added to the cart, summing up the total of our order. Feel free to add as many products as you would like 😉.

### Business rules

To make the sales team work easier, we have a json file in our app named `products.json` where they can setup our business rules for discounting when shopping.

Take a look 👀.

```
[
  {
  "name": "Voucher",
  "code": "VOUCHER",
  "price": 5.00,
  "discount_rules": {
    "quantity": 2,
    "new_price" : 0.00
  }
 },
 {
  "name": "T-Shirt",
  "code": "TSHIRT",
  "price": 20.00,
  "discount_rules": {
    "quantity": 3,
    "new_price" : 19.00
  }
 }
]
```

As showed above, we have a discounting on Vouchers. When the quantity is 2, the price will be 0.00, meaning that buying two of these items you'll pay the price of one.
And for the T-shirts, when we add the quantity of 3, the price will be 19.00. Meaning that buying three or more, the items will have the price of 19.00.

Let's go buying.

```
iex(2)> Checkout.scan("VOUCHER")
{:ok,
 %{
   cart: [
     %{code: "VOUCHER", name: "Voucher", price: 5.0},
     %{code: "VOUCHER", name: "Voucher", price: 5.0}
   ],
   discount: "5.00",
   total: "5.00€"
 }}
 ````

Since we added a voucher previously, I added one more voucher to our shopping cart and look at the total of 5.00 with the discount of 5.00 as well, which shows that our business rules is applying.

Let's get some T's.

```
Checkout.scan("TSHIRT")
{:ok,
 %{
   cart: [
     %{code: "VOUCHER", name: "Voucher", price: 5.0},
     %{code: "VOUCHER", name: "Voucher", price: 5.0},
     %{code: "TSHIRT", name: "T-Shirt", price: 20.0},
     %{code: "TSHIRT", name: "T-Shirt", price: 20.0},
     %{code: "TSHIRT", name: "T-Shirt", price: 20.0}
   ],
   discount: "8.00",
   total: "62.00€"
 }}
```

So here we added three T-shirts to the cart, and when the third one was added, our discount raised from 5.00 to 8.00, which means 3.00 more on discounts. That is correct since the price for tshirts when there's three or more, lower from 20.00 to 19.00 each.

### Terminating session

Since finishing the shooping isn't still in our scope of features, that's it for now.
So if you want to just check out what's on the cart without adding more producrts, use the read function.

```
iex(10)> Cart.read("cart")
{:ok,
 [
   %{
     "code" => "VOUCHER",
     "discount_rules" => %{"new_price" => 0.0, "quantity" => 2},
     "name" => "Voucher",
     "price" => 5.0
   },
   %{
     "code" => "VOUCHER",
     "discount_rules" => %{"new_price" => 0.0, "quantity" => 2},
     "name" => "Voucher",
     "price" => 5.0
   }
]}
```
*Note: The `"cart"` string passed in the function is the file name, if you wish to change the file name, change it at `config/config.exs` under the `:cart_path` config.*

And at last but not least, if you want to terminate the session or start all over. Just do this to clear up your cart.

```
iex(11)> Cart.clear
{:ok, "Cart cleared successfully!"}
```

And you should be all done to start "shopping" again.

## Tests

This application is 100% tested.
To run the tests, you must terminate the iterative mode terminal session. Inisde the root dir on the terminal type `mix coveralls` to check tests coverage.

![alt text](./resources/Screenshot%202022-11-15%20at%2013.00.35.png)
