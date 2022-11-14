defmodule ProductTest do
  use ExUnit.Case

  test "get_products/0 should return all products json" do
    assert {:ok, products} =
             Application.get_env(:checkout, :products_path)
             |> Product.get_products()

    assert List.first(products) |> Map.has_key?("code")
    assert List.first(products) |> Map.has_key?("name")
    assert List.first(products) |> Map.has_key?("price")
  end

  test "get_products/0 should return error when invalid path" do
    assert {:error, "Error! Please check if given path is valid."} =
             Product.get_products("invalid.json")
  end

  test "get_by_code/1 should return product json" do
    assert {:ok, product} = Product.get_by_code("VOUCHER")
    assert Map.get(product, "code") == "VOUCHER"
    assert Map.get(product, "name") == "Voucher"
  end

  test "get_by_code/1 should return error when invalid product" do
    assert {:error, "Product not found!"} = Product.get_by_code("CODE")
  end
end
