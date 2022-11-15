defmodule Cart do
  @moduledoc """
  Documentation for `Checkout`.
  """
  @cart_path Application.compile_env(:checkout, :cart_path)

  @doc """
  Adds a product to the cart.

  ## Examples

    iex> Cart.add(%{code: "VOUCHER", ...})
    {:ok, %{code: "VOUCHER", name: "Voucher", price: 5.0}}
  """
  def add(product) do
    with {:ok, cart} <- read(@cart_path) do
      (cart ++ [product])
      |> :erlang.term_to_binary()
      |> write(@cart_path)

      read(@cart_path)
    end
  end

  @doc """
  Adds a product to the cart.

  ## Examples

    iex> Cart.add(%{code: "VOUCHER", ...})
    {:ok, %{code: "VOUCHER", name: "Voucher", price: 5.0}}
  """
  def read(path) do
    case File.read(path) do
      {:ok, cart} ->
        {:ok, cart |> :erlang.binary_to_term()}

      {:error, :enoent} ->
        create_cart_file(path)
    end
  end

  defp create_cart_file(path) do
    with :ok <- File.write!(path, :erlang.term_to_binary([])),
         {:ok, cart_content} <- File.read(path) do
      {:ok, cart_content |> :erlang.binary_to_term()}
    end
  end

  defp write(content, path) do
    File.write!(path, content)
  end

  def clear do
    case File.rm(@cart_path) do
      :ok ->
        {:ok, "Cart cleared successfully!"}

      _ ->
        {:error, "Could not clear cart. Please, try again later."}
    end
  end
end
