defmodule Product do
  @moduledoc """
  Documentation for `Product`.
  """
  @products_path Application.compile_env(:checkout, :products_path)

  @doc """
  Get all products
  """
  def get_products(path) do
    with {:ok, content} <- File.read(path),
         {:ok, content} <- Poison.decode(content) do
      {:ok, content}
    else
      {:error, _} ->
        {:error, "Error! Please check if given path is valid."}
    end
  end

  @doc """
  Gets a single product by code.
  """
  def get_by_code(code) do
    {:ok, products} =
      @products_path
      |> get_products()

    products
    |> Enum.find(&(Map.get(&1, "code") == code))
    |> case do
      nil ->
        {:error, "Product not found!"}

      product ->
        {:ok, product}
    end
  end
end
