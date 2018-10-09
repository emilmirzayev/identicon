defmodule Identicon.Image do
  @moduledoc """
  Module for keeping `struct`properties of an *Image* input.
  Available properties:
  - hex. Hashed string list converted to binaries with a length of 16. Defaults to `nil`
  - color. First 3 elements of a hex array. Stands for red, green, blue values. Defaults to `nil`
  - grid. Grid of numbers used to fill up the identicon. Defaults to `nil`
  - pixel_map. Map of coordinates with x, y values to fill up identicon

  """
  defstruct hex: nil, color: nil, grid: nil, pixel_map: nil
end
