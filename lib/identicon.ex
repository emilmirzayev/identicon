defmodule Identicon do
  @moduledoc """
  Identicon application for generating a random identicon based on user input string.
  Generates an image and saves it to current directory under `user_input.png`

  Docs can be found under **doc** directory
  """


  @doc """
  Main function of the application
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Saves the given image under the `user_input.png` name
  """
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  @doc """
  Draws the image with given `color` and `pixel_map` properties using `egd` library from Erlang
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
  Builds an image sized 250x250 and coloring the squares based on `grid` property of the struct
  Sets output to `pixel_map` property of *Identicon.Image* struct
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    # 250px X 250px
    pixel_map = Enum.map grid, fn({_, index }) ->
                horizontal = rem(index, 5) * 50
                vertical = div(index, 5) * 50

                top_left = {horizontal, vertical}
                bottom_right = {horizontal + 50, vertical + 50}

                {top_left, bottom_right}
                end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Filters out odd elements from the given grid, keeping only even numbered ones.
  Sets output to `grid` property of *Identicon.Image* struct
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image ) do
    grid =  Enum.filter grid, fn({code, _ } = _ ) ->
              rem(code, 2) == 0
            end
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Builds a 5x5 grid based on `hex` array of 16 elements. Drops the last element, groups them by 3, mirrors and adds indexes.
  Sets output to `grid` property of *Identicon.Image* struct
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Generates a new center mirrored array from the given three element array by mirroring the first two elements as fourth and fifth

  ## Examples

      iex> Identicon.mirror_row([1,2,3])
      [1, 2, 3, 2, 1]

  """
  def mirror_row(row) do
    [first, second | _ ] = row
    row ++ [second, first]
  end

  @doc """
  Picks the first three element of the `hex` array as color codes for RGB values
  Sets the output to the `color` property of *Identicon.Image* struct
  """
  def pick_color(%Identicon.Image{hex: [red, green, blue | _ ]} = image) do

    %Identicon.Image{image | color: {red, green, blue}}
  end


  @doc """
  Generates a list of lenght 16 consisting of md5 hashed string converted to binaries.
  Sets the output to `hex` property of *Identicon.Image* struct.

  ## Examples

      iex> Identicon.hash_input("World")
      %Identicon.Image{
        color: nil,
        grid: nil,
        hex: [245, 167, 146, 78, 98, 30, 132, 201, 40, 10, 154, 39, 225, 188, 183,
        246],
        pixel_map: nil
        }

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

end
