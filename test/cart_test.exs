defmodule CartTest do
  @moduledoc """
  Documentation for `CartTest`.
  """
  use ExUnit.Case

  @cart_path Application.compile_env(:checkout, :cart_path)

  setup do
    on_exit(fn ->
      File.rm(@cart_path)
    end)

    {:ok, %{product: Product.get_by_code("VOUCHER")}}
  end

  test "add/1 returns cart with products added", %{product: product} do
    assert {:ok, cart} = Cart.add(product)
    assert length(cart) > 0
  end

  test "read/1 creates a file when not found" do
    assert File.exists?(@cart_path) == false
    assert {:ok, _cart} = Cart.read(@cart_path)
    assert File.exists?(@cart_path) == true
  end

  test "read/1 reads a file when exists" do
    File.write!(@cart_path, :erlang.term_to_binary([]))
    assert File.exists?(@cart_path) == true
    assert {:ok, _cart} = Cart.read(@cart_path)
  end

  test "clear/0 clears cart and deletes file" do
    File.write!(@cart_path, :erlang.term_to_binary([]))
    assert File.exists?(@cart_path) == true
    assert {:ok, "Cart cleared successfully!"} = Cart.clear()
    assert assert File.exists?(@cart_path) == false
  end

  test "clear/0 returns error when no valid path" do
    assert {:error, "Could not clear cart. Please, try again later."} = Cart.clear()
  end
end
