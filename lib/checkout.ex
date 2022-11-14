defmodule Checkout do
  @moduledoc """
  Documentation for `Checkout`.
  """

  @doc """
  Scans a product applying it's pricing rules and saving to a file.

  ## Examples

      iex> Checkout.scan("VOUCHER")
      {:ok, %{code: "VOUCHER", name: "Voucher", price: 5.0}}
  """
  def scan(code) when is_nil(code) or code == "", do: {:error, "Invalid product scan!"}

  def scan(code) do
    with {:ok, product} <- Product.get_by_code(code),
         {:ok, cart} <- Cart.add(product),
         {total, discount} <- apply_discounts(cart) do
      {:ok,
       %{
         cart: format_cart(cart),
         discount: format_value(discount),
         total: "#{format_value(total)}€"
       }}
    end
  end

  defp format_value(value), do: :erlang.float_to_binary(value, decimals: 2)

  defp format_cart(cart) do
    Enum.map(
      cart,
      &%{
        code: &1["code"],
        name: &1["name"],
        price: &1["price"]
      }
    )
  end

  defp apply_discounts(cart) do
    total = Enum.reduce(cart, 0, &(Map.get(&1, "price") + &2))

    cart_discount =
      merge_cart_with_discounts(cart)
      |> Enum.reduce(0, &(Map.get(&1, "price") + &2))

    {cart_discount, total - cart_discount}
  end

  defp merge_cart_with_discounts(cart) do
    with {:ok, voucher} <- Product.get_by_code("VOUCHER"),
         {:ok, tshirt} <- Product.get_by_code("TSHIRT"),
         voucher_cart <- apply_discount(cart, voucher),
         tshirt_cart <- apply_discount(cart, tshirt),
         cart_discounted <- voucher_cart ++ tshirt_cart do
      Enum.filter(cart, &(&1["code"] != "VOUCHER" and &1["code"] != "TSHIRT")) ++ cart_discounted
    end
  end

  defp apply_discount(cart, %{"code" => code} = product) when code == "VOUCHER" do
    Enum.filter(cart, &(&1["code"] == product["code"]))
    |> Enum.with_index(fn x, index ->
      if rem(index + 1, product["discount_rules"]["quantity"]) == 0,
        do: Map.put(x, "price", product["discount_rules"]["new_price"]),
        else: x
    end)
  end

  defp apply_discount(cart, %{"code" => code} = product) when code == "TSHIRT" do
    tshirts_cart = Enum.filter(cart, &(&1["code"] == product["code"]))

    if length(tshirts_cart) >= product["discount_rules"]["quantity"] do
      Enum.map(tshirts_cart, &Map.put(&1, "price", product["discount_rules"]["new_price"]))

    else
      tshirts_cart
    end
  end
end
