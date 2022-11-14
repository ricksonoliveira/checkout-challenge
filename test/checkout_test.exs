defmodule CheckoutTest do
  use ExUnit.Case

  @cart_path Application.compile_env(:checkout, :cart_path)

  setup do
    on_exit(fn ->
      File.rm(@cart_path)
    end)
  end

  test "scan/1 returns cart with valid data" do
    assert {:ok, %{cart: [_product], total: total, discount: discount}} = Checkout.scan("VOUCHER")
    assert total == "5.00€"
    assert discount == "0.00"
  end

  test "scan/1 with 2 or more vouchers applies discounts" do
    assert {:ok, %{cart: [_product]}} = Checkout.scan("VOUCHER")

    assert {:ok, %{cart: [_product, _product2], total: total, discount: discount}} =
             Checkout.scan("VOUCHER")

    assert total == "5.00€"
    assert discount == "5.00"
  end

  test "scan/1 with 3 or more tshirts applies discounts" do
    assert {:ok, %{cart: [_product]}} = Checkout.scan("TSHIRT")

    assert {:ok, %{cart: [_product, _product2]}} = Checkout.scan("TSHIRT")

    assert {:ok, %{cart: [_product, _product2, _product3], total: total, discount: discount}} =
             Checkout.scan("TSHIRT")

    assert total == "57.00€"
    assert discount == "3.00"
  end

  test "scan/1 when invalid code returns error" do
    assert {:error, "Invalid product scan!"} = Checkout.scan("")
  end

  test "scan/1 when code not found returns error" do
    assert {:error, "Product not found!"} = Checkout.scan("INVALID")
  end
end
